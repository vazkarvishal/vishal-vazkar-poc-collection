#!/usr/bin/env python3
"""
Terraform Threat Model README Generator
Converts Checkov JSON output to threat model markdown table
"""

import json
import argparse
import os
import shutil
from datetime import datetime
from typing import Dict, List, Any

# Checkov imports
from checkov.runner_filter import RunnerFilter
from checkov.terraform.runner import Runner as TerraformRunner

class ThreatModelReadmeGenerator:
    def __init__(self):
        # Risk level calculation based on Checkov severity
        self.severity_to_risk = {
            'CRITICAL': 'High',
            'HIGH': 'High', 
            'MEDIUM': 'Medium',
            'LOW': 'Low',
            'INFO': 'Low'
        }

    def clear_checkov_cache(self):
        """Clear Checkov cache to ensure fresh results"""
        try:
            # Common Checkov cache locations
            cache_dirs = [
                os.path.expanduser("~/.checkov"),
                os.path.expanduser("~/.cache/checkov"),
                ".checkov"
            ]
            
            for cache_dir in cache_dirs:
                if os.path.exists(cache_dir):
                    print(f"🧹 Clearing cache: {cache_dir}")
                    shutil.rmtree(cache_dir, ignore_errors=True)
                    
        except Exception as e:
            print(f"⚠️  Could not clear cache: {str(e)} (continuing anyway)")

    def run_checkov_library(self, terraform_path: str, force_refresh: bool = True) -> List[Dict]:
        """Run Checkov using the Python library directly"""
        print(f"🔍 Running Checkov scan on {terraform_path}")
        
        # Clear cache for fresh results if requested
        if force_refresh:
            self.clear_checkov_cache()
        
        # Verify path exists
        if not os.path.exists(terraform_path):
            raise Exception(f"Path does not exist: {terraform_path}")
        
        try:
            # Initialize Terraform runner with fresh instance
            runner = TerraformRunner()
            
            # Create runner filter (configure what to scan)
            runner_filter = RunnerFilter(
                framework=['terraform'],
                show_progress_bar=False,
                # Add more explicit configuration
                checks=None,  # Run all checks
                skip_checks=None,  # Don't skip any checks
                # Force fresh scan
                download_external_modules=False,
                evaluate_variables=True
            )
            
            print(f"📁 Scanning directory: {os.path.abspath(terraform_path)}")
            print(f"📄 Looking for .tf files...")
            
            # Check if there are actually .tf files
            tf_files = []
            for root, dirs, files in os.walk(terraform_path):
                for file in files:
                    if file.endswith('.tf'):
                        tf_files.append(os.path.join(root, file))
            
            print(f"🔍 Found {len(tf_files)} .tf files: {[os.path.basename(f) for f in tf_files[:5]]}")
            
            if not tf_files:
                print("⚠️  No .tf files found in the specified directory")
                return []
            
            # Run the scan
            results = runner.run(
                root_folder=terraform_path,
                runner_filter=runner_filter,
                files=None  # Let it discover files
            )
            
            print(f"✅ Checkov scan completed")
            print(f"📊 Results summary:")
            print(f"   - Passed checks: {len(results.passed_checks)}")
            print(f"   - Failed checks: {len(results.failed_checks)}")
            print(f"   - Skipped checks: {len(results.skipped_checks)}")
            
            # Convert results to our format
            findings = []
            for failed_check in results.failed_checks:
                print(f"🔍 Processing check: {failed_check.check_id} - {failed_check.check_name}")
                
                # Safely get severity with proper default handling
                severity = getattr(failed_check, 'severity', None)
                if severity is None:
                    severity = 'MEDIUM'
                else:
                    severity = str(severity).upper()
                
                findings.append({
                    'threat': failed_check.check_id,
                    'severity': severity,
                    'resource': failed_check.resource,
                    'file_path': failed_check.file_path,
                    'description': failed_check.check_name,
                    'guideline': getattr(failed_check, 'guideline', ''),
                    'remediation': getattr(failed_check, 'description', failed_check.check_name),
                    'check_name': failed_check.check_name
                })
            
            return findings
            
        except ImportError as e:
            raise Exception(f"Checkov library not found. Please install it with: pip install checkov. Error: {str(e)}")
        except Exception as e:
            print(f"❌ Checkov execution failed: {str(e)}")
            print(f"🔧 Try running checkov manually to debug: checkov -d {terraform_path}")
            raise Exception(f"Checkov execution failed: {str(e)}")



    def deduplicate_findings(self, findings: List[Dict]) -> List[Dict]:
        """Remove duplicate findings based on check name"""
        seen = set()
        unique_findings = []
        
        for finding in findings:
            # Use check name as the key for deduplication
            key = finding['threat']
            if key not in seen:
                seen.add(key)
                unique_findings.append(finding)
        
        return unique_findings

    def convert_to_threat_description(self, finding: Dict) -> str:
        """Convert Checkov check name to user-friendly threat description"""
        threat = finding['threat']
        
        # Use Checkov's description if available, otherwise convert check name
        if finding.get('description'):
            return finding['description']
        
        # Simple conversion for common Checkov checks
        conversions = {
            'CKV_AWS_10': 'RDS instances without backup retention',
            'CKV_AWS_16': 'RDS instances without encryption',
            'CKV_AWS_17': 'RDS instances publicly accessible',
            'CKV_AWS_21': 'S3 bucket versioning not enabled',
            'CKV_AWS_18': 'S3 bucket logging not enabled',
            'CKV_AWS_144': 'S3 bucket without encryption',
            'CKV_AWS_7': 'DynamoDB table encryption not enabled',
            'CKV_AWS_28': 'DynamoDB point in time recovery not enabled',
            'CKV_AWS_91': 'Load balancer without access logging',
            'CKV_AWS_92': 'ELB with insecure SSL policy',
            'CKV_AWS_79': 'Instance without detailed monitoring'
        }
        
        if threat in conversions:
            return conversions[threat]
        
        # Generic conversion - remove CKV prefix and make readable
        if threat.startswith('CKV_'):
            return threat.replace('CKV_AWS_', '').replace('_', ' ').title()
        
        return threat

    def get_mitigation_from_checkov(self, finding: Dict) -> str:
        """Get mitigation from Checkov's guideline or generate based on check"""
        # Use Checkov's guideline if available
        if finding.get('guideline'):
            return finding['guideline']
        
        # Use remediation if available
        if finding.get('remediation'):
            return finding['remediation']
        
        # Fallback based on common check patterns
        threat_lower = finding['threat'].lower()
        
        if 'encryption' in threat_lower:
            return 'Enable encryption at rest and in transit'
        elif 'backup' in threat_lower or 'retention' in threat_lower:
            return 'Configure backup retention and recovery'
        elif 'logging' in threat_lower:
            return 'Enable comprehensive logging and monitoring'
        elif 'public' in threat_lower or 'accessible' in threat_lower:
            return 'Restrict public access, use private subnets'
        elif 'versioning' in threat_lower:
            return 'Enable versioning and lifecycle policies'
        elif 'ssl' in threat_lower or 'tls' in threat_lower:
            return 'Configure secure SSL/TLS policies'
        else:
            return 'Follow AWS security best practices'

    def determine_likelihood(self, finding: Dict) -> str:
        """Determine likelihood based on Checkov severity"""
        severity = finding['severity'].upper()
        
        if severity in ['CRITICAL', 'HIGH']:
            return 'High'
        elif severity == 'MEDIUM':
            return 'Medium'
        else:
            return 'Low'

    def determine_impact(self, finding: Dict) -> str:
        """Determine impact based on threat type and severity"""
        severity = finding['severity'].upper()
        threat_lower = finding['threat'].lower()
        
        # Critical/High severity items are high impact
        if severity in ['CRITICAL', 'HIGH']:
            return 'High'
        
        # Data-related threats are typically high impact
        high_impact_keywords = ['encryption', 'backup', 'public', 'accessible', 'rds', 'dynamodb', 's3']
        if any(keyword in threat_lower for keyword in high_impact_keywords):
            return 'High'
        
        # Default to medium for other findings
        return 'Medium'

    def calculate_risk_level(self, likelihood: str, impact: str) -> str:
        """Calculate risk level from likelihood and impact"""
        if likelihood == 'High' and impact == 'High':
            return 'High'
        elif likelihood == 'High' or impact == 'High':
            return 'High'
        elif likelihood == 'Medium' or impact == 'Medium':
            return 'Medium'
        else:
            return 'Low'

    def determine_status(self, finding: Dict) -> str:
        """Determine implementation status based on severity"""
        severity = finding['severity'].upper()
        
        if severity in ['CRITICAL', 'HIGH']:
            return '⚠️'  # Needs immediate work
        elif severity == 'MEDIUM':
            return '⚠️'  # Needs work
        else:
            return '🔄'  # Can assess later

    def generate_threat_table(self, findings: List[Dict]) -> List[Dict]:
        """Convert Checkov findings to threat model table format"""
        threats = []
        
        for finding in findings:
            likelihood = self.determine_likelihood(finding)
            impact = self.determine_impact(finding)
            risk_level = self.calculate_risk_level(likelihood, impact)
            
            threat_entry = {
                'threat': self.convert_to_threat_description(finding),
                'mitigation': self.get_mitigation_from_checkov(finding),
                'likelihood': likelihood,
                'impact': impact,
                'risk_level': risk_level,
                'status': self.determine_status(finding),
                'checkov_id': finding['threat'],  # Keep Checkov ID for reference
                'resource': finding['resource']
            }
            
            threats.append(threat_entry)
        
        return threats

    def generate_markdown(self, threats: List[Dict], title: str = "AWS Infrastructure") -> str:
        """Generate the complete markdown threat model document"""
        
        current_date = datetime.now().strftime("%B %d, %Y")
        review_date = datetime.now().replace(month=(datetime.now().month + 2) % 12 + 1)
        
        markdown = f"""# 🛡️ {title} Threat Model

## Risk Assessment Framework

### Risk Calculation
**Risk Level = Likelihood × Impact**

### Likelihood Definitions
- **High**: Happens regularly, easy to exploit, common attack vector
- **Medium**: Possible with some effort, moderate skill required  
- **Low**: Difficult to exploit, requires advanced skills/access

### Impact Definitions
- **High**: Data breach, service outage, financial loss, compliance violation
- **Medium**: Degraded performance, limited data exposure, temporary issues
- **Low**: Minor inconvenience, no data loss, easily recoverable

### Risk Matrix
| Likelihood | High Impact | Medium Impact | Low Impact |
|------------|-------------|---------------|------------|
| **High** | **HIGH RISK** | **HIGH RISK** | Medium Risk |
| **Medium** | **HIGH RISK** | Medium Risk | Low Risk |
| **Low** | Medium Risk | Low Risk | Low Risk |

---

## Threat Analysis

| What Could Go Wrong | How We Stop It | Likelihood | Impact | Risk Level |
|---------------------|----------------|------------|--------|------------|
"""
        
        # Add threat rows
        for threat in threats:
            markdown += f"| **{threat['threat']}** | {threat['mitigation']} | {threat['likelihood']} | {threat['impact']} | {threat['risk_level']} {threat['status']} |\n"
        
        # Add status summary
        total_threats = len(threats)
        implemented = len([t for t in threats if t['status'] == '✅'])
        needs_work = len([t for t in threats if t['status'] == '⚠️'])
        post_launch = len([t for t in threats if t['status'] == '🔄'])
        
        high_risk = len([t for t in threats if t['risk_level'] == 'High'])
        medium_risk = len([t for t in threats if t['risk_level'] == 'Medium'])
        low_risk = len([t for t in threats if t['risk_level'] == 'Low'])
        
        markdown += f"""
## Status Summary
- ✅ = **Implemented** (control is in place and effective)
- ⚠️ = **Needs work** (control exists but requires enhancement)
- 🔄 = **Post-launch assessment** (will evaluate after production data available)

**Current State**: {implemented}/{total_threats} controls fully implemented, {post_launch} deferred to post-launch
**High Risk Items**: {high_risk} total ({len([t for t in threats if t['risk_level'] == 'High' and t['status'] == '⚠️'])} need work)
**Medium Risk Items**: {medium_risk} total ({len([t for t in threats if t['risk_level'] == 'Medium' and t['status'] == '⚠️'])} need work)
**Low Risk Items**: {low_risk} total

## Next Steps
"""
        
        # Generate next steps based on findings
        priority_items = [t for t in threats if t['status'] == '⚠️' and t['risk_level'] == 'High'][:3]
        
        for i, item in enumerate(priority_items, 1):
            markdown += f"{i}. **{item['threat']}** - {item['mitigation']}\n"
        
        # Add medium priority items if we have space
        if len(priority_items) < 3:
            medium_items = [t for t in threats if t['status'] == '⚠️' and t['risk_level'] == 'Medium'][:3-len(priority_items)]
            for item in medium_items:
                priority_items.append(item)
                markdown += f"{len(priority_items)}. **{item['threat']}** - {item['mitigation']}\n"
        
        if post_launch > 0:
            markdown += f"{len(priority_items) + 1}. **Post-Launch Assessment** - Review {post_launch} items after 30 days in production\n"
        
        # Add generation info
        markdown += f"\n---\n*Generated from Checkov security scan on {current_date}*\n"
        
        return markdown

    def update_existing_threat_model(self, output_file: str, new_threats: List[Dict], title: str) -> str:
        """Update existing threat model or create new one"""
        
        if os.path.exists(output_file):
            print(f"📝 Updating existing threat model: {output_file}")
            
            # Read existing file to preserve any custom content
            with open(output_file, 'r') as f:
                existing_content = f.read()
            
            # Check if it's our generated format
            if "Risk Assessment Framework" in existing_content:
                print("🔄 Detected existing generated threat model - will overwrite")
                return self.generate_markdown(new_threats, title)
            else:
                print("⚠️  Existing file doesn't appear to be generated by this tool")
                print("🔄 Creating backup and generating new version")
                
                # Create backup
                backup_file = f"{output_file}.backup.{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                shutil.copy2(output_file, backup_file)
                print(f"💾 Backup created: {backup_file}")
                
                return self.generate_markdown(new_threats, title)
        else:
            print(f"📄 Creating new threat model: {output_file}")
            return self.generate_markdown(new_threats, title)

    def run(self, terraform_path: str, output_file: str = "THREAT_MODEL.md", title: str = "AWS Infrastructure", force_refresh: bool = True):
        """Main execution function"""
        
        try:
            print(f"🔧 Running Checkov on Terraform directory: {terraform_path}")
            if force_refresh:
                print("🔄 Force refresh enabled - clearing cache for fresh results")
            
            findings = self.run_checkov_library(terraform_path, force_refresh)
            
            print(f"🔍 DEBUG: Raw findings count: {len(findings)}")
            if findings:
                print("🔍 DEBUG: First few findings:")
                for i, finding in enumerate(findings[:3]):
                    print(f"   {i+1}. {finding['threat']} - {finding['description']}")
            
            if not findings:
                print("✅ No security issues found! Your infrastructure looks secure.")
                # Still generate a minimal threat model
                threats = []
            else:
                print(f"📋 Loaded {len(findings)} findings from Checkov")
                
                # Deduplicate findings
                unique_findings = self.deduplicate_findings(findings)
                print(f"🔄 After deduplication: {len(unique_findings)} unique threats")
                
                print(f"🔍 DEBUG: Sample unique findings:")
                for i, finding in enumerate(unique_findings[:3]):
                    print(f"   {i+1}. {finding['threat']} - {finding['description']}")
                
                # Generate threat model
                threats = self.generate_threat_table(unique_findings)
                print(f"🔍 DEBUG: Generated threats count: {len(threats)}")
                
                if threats:
                    print(f"🔍 DEBUG: Sample threats:")
                    for i, threat in enumerate(threats[:3]):
                        print(f"   {i+1}. {threat['threat']} - Risk: {threat['risk_level']} - Status: {threat['status']}")
            
            # Generate/update markdown
            markdown_content = self.update_existing_threat_model(output_file, threats, title)
            print(f"🔍 DEBUG: Generated markdown length: {len(markdown_content)} characters")
            
            # Write to file
            with open(output_file, 'w') as f:
                f.write(markdown_content)
            
            print(f"✅ Threat model {'updated' if os.path.exists(output_file) else 'generated'}: {output_file}")
            
            if threats:
                print(f"📊 Total threats identified: {len(threats)}")
                
                # Print summary
                high_risk = len([t for t in threats if t['risk_level'] == 'High'])
                medium_risk = len([t for t in threats if t['risk_level'] == 'Medium'])
                needs_work = len([t for t in threats if t['status'] == '⚠️'])
                
                print(f"🔴 High risk items: {high_risk}")
                print(f"🟡 Medium risk items: {medium_risk}")
                print(f"⚠️  Items needing work: {needs_work}")
                
                # Show what changed if this is an update
                if os.path.exists(output_file):
                    print(f"🔄 File updated with current scan results")
            else:
                print("🎉 No security threats detected!")
                
        except Exception as e:
            print(f"❌ Error: {str(e)}")
            raise

def main():
    parser = argparse.ArgumentParser(description='Generate threat model from Terraform code using Checkov')
    
    parser.add_argument('terraform_path', help='Path to Terraform directory to scan')
    parser.add_argument('--output', '-o', default='THREAT_MODEL.md', help='Output markdown file (default: THREAT_MODEL.md)')
    parser.add_argument('--title', default='AWS Infrastructure', help='Title for the threat model')
    parser.add_argument('--no-cache-clear', action='store_true', help='Skip clearing Checkov cache (faster but may use stale results)')
    
    args = parser.parse_args()
    
    generator = ThreatModelReadmeGenerator()
    generator.run(
        terraform_path=args.terraform_path,
        output_file=args.output, 
        title=args.title,
        force_refresh=not args.no_cache_clear
    )

if __name__ == "__main__":
    main()