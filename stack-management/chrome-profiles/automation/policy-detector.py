#!/usr/bin/env python3
"""
Chrome Policy Detection System
Analyzes chrome://policy data to distinguish admin-controlled vs user-controllable settings.
"""

import json
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set, Optional

class ChromePolicyDetector:
    def __init__(self):
        self.chrome_config_dir = Path.home() / ".config/google-chrome"
        self.profiles = self._discover_profiles()

    def _discover_profiles(self) -> Dict[str, Dict]:
        """Discover all Chrome profiles and their basic info."""
        local_state_file = self.chrome_config_dir / "Local State"
        profiles = {}

        if not local_state_file.exists():
            return profiles

        try:
            with open(local_state_file, 'r') as f:
                local_state = json.load(f)

            profile_cache = local_state.get('profile', {}).get('info_cache', {})

            for profile_id, profile_info in profile_cache.items():
                profiles[profile_id] = {
                    'name': profile_info.get('name', 'Unknown'),
                    'email': profile_info.get('user_name', 'No email'),
                    'path': self.chrome_config_dir / profile_id,
                    'managed': profile_info.get('is_supervised', False),
                    'account_type': self._classify_account_type(profile_info.get('user_name', ''))
                }

        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Warning: Could not read Chrome Local State: {e}")

        return profiles

    def _classify_account_type(self, email: str) -> str:
        """Classify account type based on email domain."""
        if not email or '@' not in email:
            return 'unknown'

        domain = email.split('@')[1].lower()

        if domain == 'gmail.com':
            return 'consumer'
        elif domain in ['googlemail.com']:
            return 'consumer'
        else:
            return 'enterprise'

    def detect_profile_policies(self, profile_id: str) -> Dict:
        """
        Analyze a specific profile for enterprise policies.

        Note: This requires manual policy export from chrome://policy
        since there's no direct API access to policy data.
        """
        profile_info = self.profiles.get(profile_id, {})

        analysis = {
            'profile_id': profile_id,
            'profile_name': profile_info.get('name', 'Unknown'),
            'email': profile_info.get('email', 'No email'),
            'account_type': profile_info.get('account_type', 'unknown'),
            'analysis_timestamp': datetime.now().isoformat(),
            'policy_detection_method': 'manual_required',
            'instructions': {
                'step1': f"Open Chrome with profile: {profile_info.get('name', profile_id)}",
                'step2': "Navigate to chrome://policy",
                'step3': "Click 'Export to JSON' button",
                'step4': f"Save as: {self._get_policy_export_path(profile_id)}",
                'step5': "Run this script again to analyze the exported data"
            },
            'policy_export_path': str(self._get_policy_export_path(profile_id)),
            'admin_controlled': [],
            'user_controllable': [],
            'unknown_policies': []
        }

        # Check if policy export already exists
        policy_file = self._get_policy_export_path(profile_id)
        if policy_file.exists():
            analysis.update(self._analyze_policy_export(policy_file))

        return analysis

    def _get_policy_export_path(self, profile_id: str) -> Path:
        """Get the expected path for policy export file."""
        return Path(__file__).parent / f"policy-exports/{profile_id}-policies.json"

    def _analyze_policy_export(self, policy_file: Path) -> Dict:
        """Analyze exported chrome://policy JSON data."""
        try:
            with open(policy_file, 'r') as f:
                policy_data = json.load(f)
        except (json.JSONDecodeError, FileNotFoundError) as e:
            return {'error': f"Could not read policy export: {e}"}

        analysis = {
            'has_policy_data': True,
            'admin_controlled': [],
            'user_controllable': [],
            'unknown_policies': [],
            'enterprise_indicators': []
        }

        # Analyze policy values from chrome://policy export
        policy_values = policy_data.get('policyValues', {})

        for scope_name, scope_data in policy_values.items():
            if scope_name == 'chrome' and 'policies' in scope_data:
                policies = scope_data['policies']

                for policy_name, policy_info in policies.items():
                    source = policy_info.get('source', 'unknown')
                    level = policy_info.get('level', 'unknown')
                    scope = policy_info.get('scope', 'unknown')
                    value = policy_info.get('value')
                    error = policy_info.get('error')

                    policy_analysis = {
                        'name': policy_name,
                        'source': source,
                        'level': level,
                        'scope': scope,
                        'value': value,
                        'error': error,
                        'controllable': self._is_user_controllable(source, level, scope)
                    }

                    if error:
                        analysis['unknown_policies'].append(policy_analysis)
                    elif policy_analysis['controllable']:
                        analysis['user_controllable'].append(policy_analysis)
                    else:
                        analysis['admin_controlled'].append(policy_analysis)

                    # Check for enterprise indicators
                    if source == 'platform' or scope == 'machine':
                        analysis['enterprise_indicators'].append(f"{policy_name}: {source}/{scope}")

        return analysis

    def _is_user_controllable(self, source: str, level: str, scope: str) -> bool:
        """Determine if a policy is user-controllable based on source/level/scope."""
        # Platform and machine policies are admin-controlled
        if source == 'platform' or scope == 'machine':
            return False

        # Mandatory policies are typically admin-controlled
        if level == 'mandatory':
            return False

        # Recommended policies can often be changed by users
        if level == 'recommended':
            return True

        # Cloud user policies might be controllable depending on organization settings
        if source == 'cloud' and scope == 'user':
            return True  # Potentially controllable, needs testing

        return False  # Conservative default

    def generate_profile_report(self, profile_id: str) -> str:
        """Generate a detailed report for a specific profile."""
        analysis = self.detect_profile_policies(profile_id)

        report = f"""
# Chrome Profile Policy Analysis Report

**Profile**: {analysis['profile_name']} ({analysis['email']})
**Account Type**: {analysis['account_type']}
**Analysis Date**: {analysis['analysis_timestamp']}

## Policy Detection Status

"""

        if analysis.get('has_policy_data'):
            admin_controlled = analysis.get('admin_controlled', [])
            user_controllable = analysis.get('user_controllable', [])
            unknown_policies = analysis.get('unknown_policies', [])

            report += f"""
**Admin-Controlled Policies**: {len(admin_controlled)}
**User-Controllable Policies**: {len(user_controllable)}
**Unknown/Error Policies**: {len(unknown_policies)}

### Enterprise Indicators
{chr(10).join(f'- {indicator}' for indicator in analysis.get('enterprise_indicators', []))}

### Admin-Controlled Policies (Cannot Change)
{chr(10).join(f'- **{p["name"]}**: {p["source"]}/{p["level"]} = {p["value"]}' for p in admin_controlled)}

### User-Controllable Policies (Can Change)
{chr(10).join(f'- **{p["name"]}**: {p["source"]}/{p["level"]} = {p["value"]}' for p in user_controllable)}

### Policies with Errors
{chr(10).join(f'- **{p["name"]}**: {p["error"]}' for p in unknown_policies)}
"""
        else:
            instructions = analysis.get('instructions', {})
            report += f"""
**Status**: Policy data not yet exported

### Required Steps:
1. {instructions.get('step1', '')}
2. {instructions.get('step2', '')}
3. {instructions.get('step3', '')}
4. {instructions.get('step4', '')}
5. {instructions.get('step5', '')}

### Export Location:
```
{analysis.get('policy_export_path', '')}
```
"""

        return report

    def run_full_analysis(self) -> None:
        """Run analysis for all discovered profiles."""
        print("🔍 Chrome Multi-Profile Policy Detection")
        print("=" * 50)

        if not self.profiles:
            print("❌ No Chrome profiles found!")
            return

        print(f"📊 Found {len(self.profiles)} Chrome profiles:")
        for profile_id, info in self.profiles.items():
            print(f"  • {info['name']} ({info['email']}) - {info['account_type']}")

        print("\n" + "=" * 50)

        # Create export directory
        export_dir = Path(__file__).parent / "policy-exports"
        export_dir.mkdir(exist_ok=True)

        # Analyze each profile
        for profile_id in self.profiles.keys():
            print(f"\n🔍 Analyzing: {self.profiles[profile_id]['name']}")
            report = self.generate_profile_report(profile_id)

            # Save report
            report_file = export_dir / f"{profile_id}-analysis.md"
            with open(report_file, 'w') as f:
                f.write(report)

            print(f"📄 Report saved: {report_file}")

        print(f"\n✅ Analysis complete! Check reports in: {export_dir}")

if __name__ == "__main__":
    detector = ChromePolicyDetector()
    detector.run_full_analysis()