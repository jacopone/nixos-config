#!/usr/bin/env python3
"""
Multi-Profile Chrome Extension Manager
Manages extensions across different Chrome profiles with policy awareness.
"""

import json
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Set, Optional, Tuple

class MultiProfileExtensionManager:
    def __init__(self):
        self.chrome_config_dir = Path.home() / ".config/google-chrome"
        self.profile_configs_dir = Path(__file__).parent.parent
        self.profiles = self._discover_profiles()

    def _discover_profiles(self) -> Dict[str, Dict]:
        """Discover all Chrome profiles and their configurations."""
        local_state_file = self.chrome_config_dir / "Local State"
        profiles = {}

        if not local_state_file.exists():
            return profiles

        try:
            with open(local_state_file, 'r') as f:
                local_state = json.load(f)

            profile_cache = local_state.get('profile', {}).get('info_cache', {})

            for profile_id, profile_info in profile_cache.items():
                config_dir = self._get_profile_config_dir(profile_id, profile_info)

                profiles[profile_id] = {
                    'id': profile_id,
                    'name': profile_info.get('name', 'Unknown'),
                    'email': profile_info.get('user_name', 'No email'),
                    'chrome_path': self.chrome_config_dir / profile_id,
                    'config_path': config_dir,
                    'account_type': self._classify_account_type(profile_info.get('user_name', '')),
                    'managed': profile_info.get('is_supervised', False)
                }

        except (json.JSONDecodeError, FileNotFoundError) as e:
            print(f"Warning: Could not read Chrome Local State: {e}")

        return profiles

    def _get_profile_config_dir(self, profile_id: str, profile_info: Dict) -> Path:
        """Map Chrome profile to our config directory."""
        email = profile_info.get('user_name', '')

        if '@gmail.com' in email:
            return self.profile_configs_dir / "personal-gmail"
        elif '@tenutalarnianone.com' in email:
            return self.profile_configs_dir / "tenuta-larnianone"
        elif '@slanciamoci.it' in email and 'jacopo' in email:
            return self.profile_configs_dir / "slanciamoci-jacopo"
        elif '@slanciamoci.it' in email and 'marina' in email:
            return self.profile_configs_dir / "slanciamoci-marina"
        else:
            return self.profile_configs_dir / f"unknown-{profile_id}"

    def _classify_account_type(self, email: str) -> str:
        """Classify account type based on email domain."""
        if not email or '@' not in email:
            return 'unknown'

        domain = email.split('@')[1].lower()
        return 'consumer' if domain in ['gmail.com', 'googlemail.com'] else 'enterprise'

    def get_profile_extensions(self, profile_id: str) -> Dict:
        """Get currently installed extensions for a profile."""
        profile_info = self.profiles.get(profile_id)
        if not profile_info:
            return {'error': f'Profile {profile_id} not found'}

        chrome_profile_path = profile_info['chrome_path']
        extensions_dir = chrome_profile_path / "Extensions"
        preferences_file = chrome_profile_path / "Preferences"

        if not extensions_dir.exists() or not preferences_file.exists():
            return {'error': 'Profile data not accessible'}

        try:
            with open(preferences_file, 'r') as f:
                prefs = json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            return {'error': 'Could not read profile preferences'}

        extensions_data = prefs.get('extensions', {}).get('settings', {})
        installed_extensions = []

        for ext_id, ext_data in extensions_data.items():
            # Skip disabled or corrupted extensions
            if ext_data.get('state', 0) != 1:  # 1 = enabled
                continue

            manifest = ext_data.get('manifest', {})

            extension_info = {
                'id': ext_id,
                'name': manifest.get('name', 'Unknown'),
                'version': manifest.get('version', 'Unknown'),
                'description': manifest.get('description', ''),
                'permissions': manifest.get('permissions', []),
                'install_time': ext_data.get('install_time', ''),
                'from_webstore': ext_data.get('from_webstore', False),
                'was_installed_by_default': ext_data.get('was_installed_by_default', False),
                'policy_controlled': self._is_policy_controlled(ext_id, profile_id)
            }

            installed_extensions.append(extension_info)

        return {
            'profile_id': profile_id,
            'profile_name': profile_info['name'],
            'email': profile_info['email'],
            'account_type': profile_info['account_type'],
            'extensions': installed_extensions,
            'total_extensions': len(installed_extensions),
            'scan_timestamp': datetime.now().isoformat()
        }

    def _is_policy_controlled(self, extension_id: str, profile_id: str) -> bool:
        """Determine if extension is controlled by enterprise policy."""
        # This would need to check against exported policy data
        # For now, return False as we can't definitively determine without policy export
        return False

    def analyze_extension_distribution(self) -> Dict:
        """Analyze extension distribution across all profiles."""
        all_extensions = {}
        profile_summaries = {}

        for profile_id in self.profiles.keys():
            profile_extensions = self.get_profile_extensions(profile_id)

            if 'error' in profile_extensions:
                continue

            profile_info = self.profiles[profile_id]
            profile_summaries[profile_id] = {
                'name': profile_info['name'],
                'email': profile_info['email'],
                'account_type': profile_info['account_type'],
                'extension_count': profile_extensions['total_extensions'],
                'extensions': profile_extensions['extensions']
            }

            # Track extension usage across profiles
            for ext in profile_extensions['extensions']:
                ext_id = ext['id']
                if ext_id not in all_extensions:
                    all_extensions[ext_id] = {
                        'name': ext['name'],
                        'profiles': [],
                        'total_installs': 0
                    }

                all_extensions[ext_id]['profiles'].append({
                    'profile_id': profile_id,
                    'profile_name': profile_info['name'],
                    'account_type': profile_info['account_type']
                })
                all_extensions[ext_id]['total_installs'] += 1

        return {
            'analysis_timestamp': datetime.now().isoformat(),
            'total_profiles': len(profile_summaries),
            'profile_summaries': profile_summaries,
            'extension_distribution': all_extensions,
            'insights': self._generate_insights(all_extensions, profile_summaries)
        }

    def _generate_insights(self, extensions: Dict, profiles: Dict) -> Dict:
        """Generate insights about extension usage patterns."""
        insights = {
            'universal_extensions': [],
            'profile_specific_extensions': [],
            'duplicate_functionalities': [],
            'security_concerns': [],
            'recommendations': []
        }

        total_profiles = len(profiles)

        for ext_id, ext_data in extensions.items():
            install_count = ext_data['total_installs']

            # Universal extensions (in all or most profiles)
            if install_count >= total_profiles * 0.75:  # 75% threshold
                insights['universal_extensions'].append({
                    'id': ext_id,
                    'name': ext_data['name'],
                    'install_count': install_count,
                    'profiles': ext_data['profiles']
                })

            # Profile-specific extensions
            if install_count == 1:
                profile_info = ext_data['profiles'][0]
                insights['profile_specific_extensions'].append({
                    'id': ext_id,
                    'name': ext_data['name'],
                    'profile': profile_info['profile_name'],
                    'account_type': profile_info['account_type']
                })

        # Generate recommendations
        if len(insights['universal_extensions']) > 0:
            insights['recommendations'].append(
                f"Consider {len(insights['universal_extensions'])} extensions as truly universal across profiles"
            )

        if len(insights['profile_specific_extensions']) > 0:
            insights['recommendations'].append(
                f"Good profile separation: {len(insights['profile_specific_extensions'])} profile-specific extensions"
            )

        return insights

    def generate_profile_extension_report(self, profile_id: str) -> str:
        """Generate detailed extension report for a specific profile."""
        profile_data = self.get_profile_extensions(profile_id)

        if 'error' in profile_data:
            return f"Error analyzing profile {profile_id}: {profile_data['error']}"

        profile_info = self.profiles[profile_id]

        report = f"""
# Extension Analysis: {profile_data['profile_name']}

**Email**: {profile_data['email']}
**Account Type**: {profile_data['account_type']}
**Total Extensions**: {profile_data['total_extensions']}
**Analysis Date**: {profile_data['scan_timestamp']}

## Extension Inventory

"""

        for ext in profile_data['extensions']:
            policy_indicator = "🔒 Policy-controlled" if ext['policy_controlled'] else "🔧 User-installed"
            webstore_indicator = "🏪 Web Store" if ext['from_webstore'] else "📦 Sideloaded"

            report += f"""
### {ext['name']} (`{ext['id']}`)
- **Version**: {ext['version']}
- **Source**: {webstore_indicator}
- **Control**: {policy_indicator}
- **Description**: {ext['description']}
- **Permissions**: {', '.join(ext['permissions'][:3])}{'...' if len(ext['permissions']) > 3 else ''}

"""

        # Add configuration recommendations
        config_path = profile_info['config_path']
        report += f"""
## Configuration Management

**Profile Config Directory**: `{config_path}`
**Recommended Actions**:

1. **Document Extensions**: Update `{config_path}/extensions.md` with current inventory
2. **Review Permissions**: Assess extension permissions for security
3. **Policy Compliance**: Ensure extensions align with account type policies
4. **Performance Impact**: Monitor resource usage of extensions

## Extension Strategy Recommendations

"""

        if profile_data['account_type'] == 'consumer':
            report += """
**Consumer Account Strategy**:
- Focus on privacy and security extensions
- Personal productivity tools
- Development and learning extensions
- Avoid business-specific tools in this profile
"""
        else:
            report += """
**Enterprise Account Strategy**:
- Business productivity and collaboration tools
- Industry-specific extensions
- Company-approved security tools
- Compliance with enterprise policies
"""

        return report

    def run_full_analysis(self) -> None:
        """Run comprehensive analysis across all profiles."""
        print("🔍 Multi-Profile Chrome Extension Analysis")
        print("=" * 60)

        if not self.profiles:
            print("❌ No Chrome profiles found!")
            return

        print(f"📊 Analyzing {len(self.profiles)} Chrome profiles:")
        for profile_id, info in self.profiles.items():
            print(f"  • {info['name']} ({info['email']}) - {info['account_type']}")

        print("\n" + "=" * 60)

        # Create reports directory
        reports_dir = Path(__file__).parent / "extension-reports"
        reports_dir.mkdir(exist_ok=True)

        # Generate individual profile reports
        print("\n📝 Generating Profile Reports:")
        for profile_id in self.profiles.keys():
            profile_info = self.profiles[profile_id]
            print(f"  📄 Analyzing: {profile_info['name']}")

            report = self.generate_profile_extension_report(profile_id)
            report_file = reports_dir / f"{profile_id}-extensions.md"

            with open(report_file, 'w') as f:
                f.write(report)

            print(f"     Saved: {report_file}")

        # Generate cross-profile analysis
        print(f"\n🔍 Cross-Profile Analysis:")
        analysis = self.analyze_extension_distribution()

        analysis_report = self._generate_cross_profile_report(analysis)
        analysis_file = reports_dir / "cross-profile-analysis.md"

        with open(analysis_file, 'w') as f:
            f.write(analysis_report)

        print(f"  📊 Cross-profile analysis: {analysis_file}")

        print(f"\n✅ Analysis complete! Reports in: {reports_dir}")

    def _generate_cross_profile_report(self, analysis: Dict) -> str:
        """Generate cross-profile analysis report."""
        insights = analysis['insights']

        report = f"""
# Chrome Multi-Profile Extension Analysis

**Analysis Date**: {analysis['analysis_timestamp']}
**Profiles Analyzed**: {analysis['total_profiles']}

## Profile Summary

"""

        for profile_id, profile_data in analysis['profile_summaries'].items():
            report += f"""
### {profile_data['name']} ({profile_data['account_type']})
- **Email**: {profile_data['email']}
- **Extensions**: {profile_data['extension_count']}
"""

        report += f"""

## Extension Distribution Insights

### Universal Extensions ({len(insights['universal_extensions'])})
Extensions installed across multiple profiles:

"""

        for ext in insights['universal_extensions']:
            profiles_list = ', '.join([p['profile_name'] for p in ext['profiles']])
            report += f"- **{ext['name']}**: {ext['install_count']} profiles ({profiles_list})\n"

        report += f"""

### Profile-Specific Extensions ({len(insights['profile_specific_extensions'])})
Extensions unique to single profiles:

"""

        for ext in insights['profile_specific_extensions']:
            report += f"- **{ext['name']}**: {ext['profile']} ({ext['account_type']})\n"

        report += """

## Recommendations

"""

        for rec in insights['recommendations']:
            report += f"- {rec}\n"

        report += """

## Next Steps

1. **Review Universal Extensions**: Determine if truly needed across all profiles
2. **Validate Profile-Specific Extensions**: Ensure proper profile separation
3. **Security Audit**: Review permissions for all extensions
4. **Policy Compliance**: Ensure enterprise extensions comply with company policies
5. **Performance Optimization**: Remove unused or redundant extensions

"""

        return report

if __name__ == "__main__":
    manager = MultiProfileExtensionManager()
    manager.run_full_analysis()
