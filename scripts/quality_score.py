#!/usr/bin/env python
"""
Quality Scoring System for Academic Project Materials

Calculates objective quality scores (0-100) based on defined rubrics.
Enforces quality gates: 80 (commit), 90 (PR), 95 (excellence).

Usage:
    python scripts/quality_score.py slides/Lecture01_Topic.tex
    python scripts/quality_score.py scripts/python/analysis.py
    python scripts/quality_score.py scripts/stata/analysis.do
    python scripts/quality_score.py slides/*.tex --summary
"""

import sys
import argparse
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple
import re
import json

# ==============================================================================
# SCORING RUBRICS (from .claude/rules/quality-gates.md)
# ==============================================================================

BEAMER_RUBRIC = {
    'critical': {
        'compilation_failure': {'points': 100, 'auto_fail': True},
        'undefined_citation': {'points': 15},
        'overfull_hbox': {'points': 10},
    },
    'major': {
        'text_overflow': {'points': 5},
        'notation_inconsistency': {'points': 3},
    },
    'minor': {
        'font_size_reduction': {'points': 1},
        'orphan_runt': {'points': 2},
    }
}

PYTHON_RUBRIC = {
    'critical': {
        'syntax_error': {'points': 100, 'auto_fail': True},
        'hardcoded_path': {'points': 20},
        'missing_import': {'points': 10},
    },
    'major': {
        'missing_seed': {'points': 10},
        'missing_docstring': {'points': 5},
        'no_main_guard': {'points': 3},
    },
    'minor': {
        'style_violation': {'points': 1},
        'long_line': {'points': 1},
    }
}

STATA_RUBRIC = {
    'critical': {
        'syntax_error': {'points': 100, 'auto_fail': True},
        'hardcoded_path': {'points': 20},
        'missing_clear_all': {'points': 10},
    },
    'major': {
        'missing_set_seed': {'points': 10},
        'missing_header': {'points': 5},
        'missing_log': {'points': 5},
    },
    'minor': {
        'style_violation': {'points': 1},
    }
}

THRESHOLDS = {
    'commit': 80,
    'pr': 90,
    'excellence': 95
}

# ==============================================================================
# ISSUE DETECTION (Lightweight checks - full agents run separately)
# ==============================================================================

class IssueDetector:
    """Detect common issues for quality scoring."""

    @staticmethod
    def check_python_syntax(filepath: Path) -> Tuple[bool, str]:
        """Check Python file for syntax errors using py_compile."""
        try:
            result = subprocess.run(
                ['python', '-m', 'py_compile', str(filepath)],
                capture_output=True,
                text=True,
                timeout=10
            )
            if result.returncode != 0:
                return False, result.stderr
            return True, ""
        except subprocess.TimeoutExpired:
            return False, "Syntax check timeout"
        except FileNotFoundError:
            return False, "Python not found"

    @staticmethod
    def check_stata_basics(content: str) -> Dict[str, List]:
        """Check Stata .do file for basic quality issues."""
        issues = {'critical': [], 'major': [], 'minor': []}
        lines = content.split('\n')

        # Check for clear all in first 20 lines
        header_region = '\n'.join(lines[:20]).lower()
        if 'clear all' not in header_region and 'clear' not in header_region:
            issues['critical'].append({
                'type': 'missing_clear_all',
                'description': 'Missing `clear all` near top of file',
                'details': 'Add `clear all` after header block',
                'points': 10
            })

        # Check for header block (comments in first 5 lines)
        first_lines = '\n'.join(lines[:5])
        if not re.search(r'^\s*(\*|//)', first_lines, re.MULTILINE):
            issues['major'].append({
                'type': 'missing_header',
                'description': 'Missing header comment block',
                'details': 'Add header with purpose, author, date',
                'points': 5
            })

        # Check for log usage
        if 'log using' not in content.lower() and 'cmdlog using' not in content.lower():
            issues['major'].append({
                'type': 'missing_log',
                'description': 'No log file opened',
                'details': 'Add `log using scripts/stata/logs/filename.smcl, replace`',
                'points': 5
            })

        # Check for set seed if randomness detected
        random_cmds = ['simulate', 'bootstrap', 'permute', 'sample', 'bsample', 'drawnorm']
        has_random = any(cmd in content.lower() for cmd in random_cmds)
        if has_random and 'set seed' not in content.lower():
            issues['major'].append({
                'type': 'missing_set_seed',
                'description': 'Missing `set seed` for reproducibility',
                'details': 'Add `set seed YYYYMMDD` after `clear all`',
                'points': 10
            })

        return issues

    @staticmethod
    def check_python_quality(content: str) -> Dict[str, List]:
        """Check Python script for quality issues."""
        issues = {'critical': [], 'major': [], 'minor': []}
        lines = content.split('\n')

        # Check for missing seed if randomness detected
        random_fns = ['np.random', 'random.', 'torch.manual_seed', 'sklearn']
        has_random = any(fn in content for fn in random_fns)
        seed_patterns = ['np.random.seed', 'random.seed', 'torch.manual_seed',
                         'np.random.default_rng', 'RandomState']
        has_seed = any(pat in content for pat in seed_patterns)
        if has_random and not has_seed:
            issues['major'].append({
                'type': 'missing_seed',
                'description': 'Missing random seed for reproducibility',
                'details': 'Add np.random.seed() or random.seed() at top of script',
                'points': 10
            })

        # Check for docstring at module level
        stripped = content.lstrip()
        if not (stripped.startswith('"""') or stripped.startswith("'''")):
            # Check if it starts with comments or imports before checking for docstring
            has_docstring = False
            for line in lines:
                l = line.strip()
                if l == '' or l.startswith('#') or l.startswith('#!/'):
                    continue
                if l.startswith('"""') or l.startswith("'''"):
                    has_docstring = True
                break
            if not has_docstring:
                issues['major'].append({
                    'type': 'missing_docstring',
                    'description': 'Missing module-level docstring',
                    'details': 'Add a docstring describing the script purpose',
                    'points': 5
                })

        # Check for if __name__ == "__main__" guard
        if 'def main' in content or 'def run' in content:
            if '__name__' not in content:
                issues['major'].append({
                    'type': 'no_main_guard',
                    'description': 'Missing `if __name__ == "__main__"` guard',
                    'details': 'Add main guard for importability',
                    'points': 3
                })

        return issues

    @staticmethod
    def check_hardcoded_paths(content: str) -> List[int]:
        """Detect absolute paths in scripts."""
        issues = []
        lines = content.split('\n')

        for i, line in enumerate(lines, 1):
            # Skip comment lines
            stripped = line.strip()
            if stripped.startswith('#') or stripped.startswith('*') or stripped.startswith('//'):
                continue
            if re.search(r'["\'][/\\](?:Users|home|tmp|var|etc)[/\\]', line):
                issues.append(i)
            elif re.search(r'["\'][A-Za-z]:[/\\]', line):
                if not re.search(r'http:|https:', line):
                    issues.append(i)

        return issues

    @staticmethod
    def check_equation_overflow(content: str) -> List[int]:
        """Detect displayed equations with single lines likely to overflow."""
        overflows = []
        lines = content.split('\n')
        in_math = False
        math_delim = None

        for i, line in enumerate(lines, 1):
            stripped = line.strip()

            if '$$' in stripped and math_delim != 'env':
                if not in_math:
                    in_math = True
                    math_delim = '$$'
                    if stripped.count('$$') >= 2:
                        inner = stripped.split('$$')[1]
                        if len(inner.strip()) > 120:
                            overflows.append(i)
                        in_math = False
                        math_delim = None
                    continue
                else:
                    in_math = False
                    math_delim = None
                    continue

            env_begin = re.match(
                r'\\begin\{(equation|align|gather|multline|eqnarray)\*?\}', stripped
            )
            if env_begin and not in_math:
                in_math = True
                math_delim = 'env'
                continue

            if re.match(r'\\end\{(equation|align|gather|multline|eqnarray)\*?\}', stripped):
                in_math = False
                math_delim = None
                continue

            if in_math:
                code_part = line.split('%')[0] if '%' in line else line
                if len(code_part.strip()) > 120:
                    overflows.append(i)

        return overflows

    @staticmethod
    def check_broken_citations(content: str, bib_file: Path) -> List[str]:
        """Check for LaTeX citation keys not in bibliography."""
        cite_pattern = r'\\cite[a-z]*\{([^}]+)\}'
        cited_keys = set()
        for match in re.finditer(cite_pattern, content):
            keys = match.group(1).split(',')
            cited_keys.update(k.strip() for k in keys)

        if not bib_file.exists():
            return list(cited_keys)

        bib_content = bib_file.read_text(encoding='utf-8')
        bib_keys = set(re.findall(r'@\w+\{([^,]+),', bib_content))

        broken = cited_keys - bib_keys
        return list(broken)

    @staticmethod
    def check_latex_syntax(content: str) -> List[Dict]:
        """Check for common LaTeX syntax issues without compiling."""
        issues = []
        lines = content.split('\n')

        env_stack = []
        for i, line in enumerate(lines, 1):
            stripped = line.split('%')[0] if '%' in line else line

            for match in re.finditer(r'\\begin\{(\w+)\}', stripped):
                env_stack.append((match.group(1), i))

            for match in re.finditer(r'\\end\{(\w+)\}', stripped):
                env_name = match.group(1)
                if env_stack and env_stack[-1][0] == env_name:
                    env_stack.pop()
                elif env_stack:
                    issues.append({
                        'line': i,
                        'description': f'Mismatched environment: \\end{{{env_name}}} '
                                       f'but expected \\end{{{env_stack[-1][0]}}} '
                                       f'(opened at line {env_stack[-1][1]})',
                    })
                else:
                    issues.append({
                        'line': i,
                        'description': f'\\end{{{env_name}}} without matching \\begin',
                    })

        for env_name, line_num in env_stack:
            issues.append({
                'line': line_num,
                'description': f'Unclosed environment: \\begin{{{env_name}}} never closed',
            })

        return issues

    @staticmethod
    def check_orphan_runts(content: str) -> List[int]:
        """Detect orphan/runt words in Beamer frames.

        A runt is a single word or very short phrase (<10 chars) that
        sits alone on the final line of a paragraph or bullet point.
        Flagged only inside frames, only when the preceding line is
        substantial text (>=30 chars), indicating the word spilled over.
        """
        issues = []
        lines = content.split('\n')
        in_frame = False
        in_tikz = False
        in_tabular = False
        in_lstlisting = False
        # LaTeX structural commands that start a line and are not prose
        struct_re = re.compile(
            r'^\s*\\(begin|end|item|section|subsection|frametitle'
            r'|includegraphics|input|vspace|hspace|centering'
            r'|column|textbf|textit|label|ref|cite|caption'
            r'|draw|node|fill|path|coordinate'  # TikZ
            r'|toprule|midrule|bottomrule'       # booktabs
            r')\b'
        )

        for i, line in enumerate(lines, 1):
            raw = line.split('%')[0] if '%' in line else line

            if r'\begin{frame}' in raw:
                in_frame = True
                continue
            if r'\end{frame}' in raw:
                in_frame = False
                continue

            # Track environments where runts don't apply
            if r'\begin{tikzpicture}' in raw:
                in_tikz = True
            if r'\end{tikzpicture}' in raw:
                in_tikz = False
                continue
            if r'\begin{tabular' in raw or r'\begin{tabbing' in raw:
                in_tabular = True
            if r'\end{tabular' in raw or r'\end{tabbing' in raw:
                in_tabular = False
                continue
            if r'\begin{lstlisting}' in raw:
                in_lstlisting = True
            if r'\end{lstlisting}' in raw:
                in_lstlisting = False
                continue

            if not in_frame or i < 2:
                continue
            if in_tikz or in_tabular or in_lstlisting:
                continue

            stripped = raw.strip()
            # Skip blank lines, comments, structural commands
            if not stripped or stripped.startswith('%'):
                continue
            if struct_re.match(stripped):
                continue
            # Skip lines that are just braces/brackets (code constructs)
            if re.match(r'^[{}\[\](),;]+$', stripped):
                continue
            # Skip intentional labels ending with colon
            if stripped.endswith(':'):
                continue
            # Skip lines starting with backslash (LaTeX commands)
            if stripped.startswith('\\'):
                continue

            # This line is short prose — check if it's a runt
            if len(stripped) >= 10:
                continue

            # Look at the previous non-blank source line
            prev_raw = ''
            for j in range(i - 2, max(i - 5, -1), -1):
                candidate = lines[j].split('%')[0] if '%' in lines[j] else lines[j]
                if candidate.strip():
                    prev_raw = candidate.strip()
                    break

            # Runt: previous line is substantial text (>=30 chars)
            # and previous line is actual prose (not a command)
            if len(prev_raw) >= 30 and not struct_re.match(prev_raw):
                issues.append(i)

        return issues

    @staticmethod
    def check_overfull_hbox_risk(content: str) -> List[int]:
        """Detect lines in LaTeX source likely to cause overfull hbox."""
        issues = []
        lines = content.split('\n')
        in_frame = False

        for i, line in enumerate(lines, 1):
            stripped = line.split('%')[0] if '%' in line else line

            if r'\begin{frame}' in stripped:
                in_frame = True
            elif r'\end{frame}' in stripped:
                in_frame = False

            if in_frame and len(stripped.strip()) > 120:
                if stripped.strip().startswith('%'):
                    continue
                if re.match(r'\s*\\(includegraphics|input|bibliography|usepackage)', stripped):
                    continue
                issues.append(i)

        return issues


# ==============================================================================
# QUALITY SCORER
# ==============================================================================

class QualityScorer:
    """Calculate quality scores for project materials."""

    def __init__(self, filepath: Path, verbose: bool = False):
        self.filepath = filepath
        self.verbose = verbose
        self.score = 100
        self.issues = {
            'critical': [],
            'major': [],
            'minor': []
        }
        self.auto_fail = False

    def score_beamer(self) -> Dict:
        """Score Beamer/LaTeX lecture slides."""
        content = self.filepath.read_text(encoding='utf-8')

        # Check for LaTeX syntax issues (without compiling)
        syntax_issues = IssueDetector.check_latex_syntax(content)
        if syntax_issues:
            for issue in syntax_issues:
                self.issues['critical'].append({
                    'type': 'compilation_failure',
                    'description': f'LaTeX syntax issue at line {issue["line"]}',
                    'details': issue['description'],
                    'points': 100
                })
            self.auto_fail = True
            self.score = 0
            return self._generate_report()

        # Check for undefined/broken citations
        bib_file = self.filepath.parent.parent / 'bibliography.bib'
        if not bib_file.exists():
            bib_file = self.filepath.parent / 'bibliography.bib'
        broken_citations = IssueDetector.check_broken_citations(content, bib_file)
        for key in broken_citations:
            self.issues['critical'].append({
                'type': 'undefined_citation',
                'description': f'Citation key not in bibliography: {key}',
                'details': 'Add to bibliography.bib or fix key',
                'points': 15
            })
            self.score -= 15

        # Check for lines likely to cause overfull hbox
        overfull_lines = IssueDetector.check_overfull_hbox_risk(content)
        for line in overfull_lines:
            self.issues['critical'].append({
                'type': 'overfull_hbox',
                'description': f'Potential overfull hbox at line {line}',
                'details': 'Line >120 chars inside frame may overflow slide width',
                'points': 10
            })
            self.score -= 10

        # Check equation overflow
        equation_overflows = IssueDetector.check_equation_overflow(content)
        for line_num in equation_overflows:
            self.issues['critical'].append({
                'type': 'overfull_hbox',
                'description': f'Potential equation overflow at line {line_num}',
                'details': 'Single equation line >120 chars likely to overflow',
                'points': 10
            })
            self.score -= 10

        # Check for orphan/runt words
        runt_lines = IssueDetector.check_orphan_runts(content)
        for line in runt_lines:
            self.issues['minor'].append({
                'type': 'orphan_runt',
                'description': f'Orphan/runt word at line {line}',
                'details': 'Short word alone on last line of text block; '
                           'rephrase to pull it back to the previous line',
                'points': 2
            })
            self.score -= 2

        self.score = max(0, self.score)
        return self._generate_report()

    def score_python(self) -> Dict:
        """Score Python script quality."""
        content = self.filepath.read_text(encoding='utf-8')

        # Check syntax
        is_valid, error = IssueDetector.check_python_syntax(self.filepath)
        if not is_valid:
            self.auto_fail = True
            self.issues['critical'].append({
                'type': 'syntax_error',
                'description': 'Python syntax error',
                'details': error[:200],
                'points': 100
            })
            self.score = 0
            return self._generate_report()

        # Check hardcoded paths
        path_issues = IssueDetector.check_hardcoded_paths(content)
        for line in path_issues:
            self.issues['critical'].append({
                'type': 'hardcoded_path',
                'description': f'Hardcoded absolute path at line {line}',
                'details': 'Use relative paths or Path() objects',
                'points': 20
            })
            self.score -= 20

        # Check Python-specific quality
        quality_issues = IssueDetector.check_python_quality(content)
        for severity in ['critical', 'major', 'minor']:
            for issue in quality_issues.get(severity, []):
                self.issues[severity].append(issue)
                self.score -= issue['points']

        self.score = max(0, self.score)
        return self._generate_report()

    def score_stata(self) -> Dict:
        """Score Stata .do file quality."""
        content = self.filepath.read_text(encoding='utf-8')

        # Check hardcoded paths
        path_issues = IssueDetector.check_hardcoded_paths(content)
        for line in path_issues:
            self.issues['critical'].append({
                'type': 'hardcoded_path',
                'description': f'Hardcoded absolute path at line {line}',
                'details': 'Use global macros ($root, $data, etc.)',
                'points': 20
            })
            self.score -= 20

        # Check Stata-specific basics
        stata_issues = IssueDetector.check_stata_basics(content)
        for severity in ['critical', 'major', 'minor']:
            for issue in stata_issues.get(severity, []):
                self.issues[severity].append(issue)
                self.score -= issue['points']

        self.score = max(0, self.score)
        return self._generate_report()

    def _generate_report(self) -> Dict:
        """Generate quality score report."""
        if self.auto_fail:
            status = 'FAIL'
            threshold = 'None (auto-fail)'
        elif self.score >= THRESHOLDS['excellence']:
            status = 'EXCELLENCE'
            threshold = 'excellence'
        elif self.score >= THRESHOLDS['pr']:
            status = 'PR_READY'
            threshold = 'pr'
        elif self.score >= THRESHOLDS['commit']:
            status = 'COMMIT_READY'
            threshold = 'commit'
        else:
            status = 'BLOCKED'
            threshold = 'None (below commit)'

        critical_count = len(self.issues['critical'])
        major_count = len(self.issues['major'])
        minor_count = len(self.issues['minor'])
        total_count = critical_count + major_count + minor_count

        return {
            'filepath': str(self.filepath),
            'score': self.score,
            'status': status,
            'threshold': threshold,
            'auto_fail': self.auto_fail,
            'issues': {
                'critical': self.issues['critical'],
                'major': self.issues['major'],
                'minor': self.issues['minor'],
                'counts': {
                    'critical': critical_count,
                    'major': major_count,
                    'minor': minor_count,
                    'total': total_count
                }
            },
            'thresholds': THRESHOLDS
        }

    def print_report(self, summary_only: bool = False) -> None:
        """Print formatted quality report."""
        report = self._generate_report()

        print(f"\n# Quality Score: {self.filepath.name}\n")

        status_emoji = {
            'EXCELLENCE': '[EXCELLENCE]',
            'PR_READY': '[PASS]',
            'COMMIT_READY': '[PASS]',
            'BLOCKED': '[BLOCKED]',
            'FAIL': '[FAIL]'
        }

        print(f"## Overall Score: {report['score']}/100 {status_emoji.get(report['status'], '')}")

        if report['status'] == 'BLOCKED':
            print(f"\n**Status:** BLOCKED - Cannot commit (score < {THRESHOLDS['commit']})")
        elif report['status'] == 'COMMIT_READY':
            print(f"\n**Status:** Ready for commit (score >= {THRESHOLDS['commit']})")
            gap_to_pr = THRESHOLDS['pr'] - report['score']
            print(f"**Next milestone:** PR threshold ({THRESHOLDS['pr']}+)")
            print(f"**Gap analysis:** Need +{gap_to_pr} points to reach PR quality")
        elif report['status'] == 'PR_READY':
            print(f"\n**Status:** Ready for PR (score >= {THRESHOLDS['pr']})")
            gap_to_excellence = THRESHOLDS['excellence'] - report['score']
            if gap_to_excellence > 0:
                print(f"**Next milestone:** Excellence ({THRESHOLDS['excellence']})")
                print(f"**Gap analysis:** +{gap_to_excellence} points to excellence")
        elif report['status'] == 'EXCELLENCE':
            print(f"\n**Status:** Excellence achieved! (score >= {THRESHOLDS['excellence']})")
        elif report['status'] == 'FAIL':
            print(f"\n**Status:** Auto-fail (compilation/syntax error)")

        if summary_only:
            print(f"\n**Total issues:** {report['issues']['counts']['total']} "
                  f"({report['issues']['counts']['critical']} critical, "
                  f"{report['issues']['counts']['major']} major, "
                  f"{report['issues']['counts']['minor']} minor)")
            return

        # Detailed issues
        print(f"\n## Critical Issues (MUST FIX): {report['issues']['counts']['critical']}")
        if report['issues']['counts']['critical'] == 0:
            print("No critical issues - safe to commit\n")
        else:
            for i, issue in enumerate(report['issues']['critical'], 1):
                print(f"{i}. **{issue['description']}** (-{issue['points']} points)")
                print(f"   - {issue['details']}\n")

        if report['issues']['counts']['major'] > 0:
            print(f"## Major Issues (SHOULD FIX): {report['issues']['counts']['major']}")
            for i, issue in enumerate(report['issues']['major'], 1):
                print(f"{i}. **{issue['description']}** (-{issue['points']} points)")
                print(f"   - {issue['details']}\n")

        if report['issues']['counts']['minor'] > 0 and self.verbose:
            print(f"## Minor Issues (NICE-TO-HAVE): {report['issues']['counts']['minor']}")
            for i, issue in enumerate(report['issues']['minor'], 1):
                print(f"{i}. {issue['description']} (-{issue['points']} points)\n")

        # Recommendations
        if report['status'] == 'BLOCKED':
            print("## Recommended Actions")
            print("1. Fix all critical issues above")
            print(f"2. Re-run quality score (target: >={THRESHOLDS['commit']})")
            print("3. Commit after reaching threshold\n")
        elif report['status'] == 'COMMIT_READY' and report['score'] < THRESHOLDS['pr']:
            print("## Recommended Actions to Reach PR Threshold")
            points_needed = THRESHOLDS['pr'] - report['score']
            print(f"Need +{points_needed} points to reach {THRESHOLDS['pr']}/100")
            if report['issues']['counts']['major'] > 0:
                print("Fix major issues listed above to improve score")


# ==============================================================================
# CLI INTERFACE
# ==============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Calculate quality scores for project materials',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Score a Beamer/LaTeX file
  python scripts/quality_score.py slides/Lecture01_Topic.tex

  # Score a Python script
  python scripts/quality_score.py scripts/python/analysis.py

  # Score a Stata .do file
  python scripts/quality_score.py scripts/stata/analysis.do

  # Score multiple files
  python scripts/quality_score.py slides/*.tex

  # Summary only (no detailed issues)
  python scripts/quality_score.py slides/Lecture01.tex --summary

  # Verbose output (include minor issues)
  python scripts/quality_score.py scripts/python/analysis.py --verbose

Quality Thresholds:
  80/100 = Commit threshold (blocks if below)
  90/100 = PR threshold (warning if below)
  95/100 = Excellence (aspirational)

Exit Codes:
  0 = Score >= 80 (commit allowed)
  1 = Score < 80 (commit blocked)
  2 = Auto-fail (compilation/syntax error)
        """
    )

    parser.add_argument('filepaths', type=Path, nargs='+', help='Path(s) to file(s) to score')
    parser.add_argument('--summary', action='store_true', help='Show summary only')
    parser.add_argument('--verbose', action='store_true', help='Show all issues including minor')
    parser.add_argument('--json', action='store_true', help='Output as JSON')

    args = parser.parse_args()

    results = []
    exit_code = 0

    for filepath in args.filepaths:
        if not filepath.exists():
            print(f"Error: File not found: {filepath}")
            exit_code = 1
            continue

        try:
            scorer = QualityScorer(filepath, verbose=args.verbose)

            if filepath.suffix == '.tex':
                report = scorer.score_beamer()
            elif filepath.suffix == '.py':
                report = scorer.score_python()
            elif filepath.suffix == '.do':
                report = scorer.score_stata()
            else:
                print(f"Error: Unsupported file type: {filepath.suffix}")
                print(f"Supported types: .tex, .py, .do")
                continue

            results.append(report)

            if not args.json:
                scorer.print_report(summary_only=args.summary)

            if report['auto_fail']:
                exit_code = max(exit_code, 2)
            elif report['score'] < THRESHOLDS['commit']:
                exit_code = max(exit_code, 1)

        except Exception as e:
            print(f"Error scoring {filepath}: {e}")
            import traceback
            traceback.print_exc()
            exit_code = 1

    if args.json:
        print(json.dumps(results, indent=2))

    sys.exit(exit_code)

if __name__ == '__main__':
    main()
