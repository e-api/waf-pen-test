# 🛡️ Advanced WAF Penetration Testing Suite

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash Version](https://img.shields.io/badge/bash-4.0%2B-brightgreen.svg)](https://www.gnu.org/software/bash/)
[![Security Testing](https://img.shields.io/badge/Security-Penetration%20Testing-red.svg)](https://owasp.org/)

A comprehensive, professional-grade Web Application Firewall (WAF) penetration testing script that simulates real-world attack scenarios to evaluate the effectiveness of your WAF implementation.

# 📋 Table of Contents

- [Features](#-features)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Test Coverage](#-test-coverage)
- [Understanding Results](#-understanding-results)
- [Advanced Usage](#-advanced-usage)
- [Interpreting WAF Effectiveness](#-interpreting-waf-effectiveness)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Disclaimer](#-disclaimer)

# ✨ Features

# Core Capabilities
- **16+ Attack Categories** covering OWASP Top 10 vulnerabilities
- **Real-world payloads** used in professional penetration testing
- **Automated evasion techniques** to test WAF robustness
- **Time-based detection** for blind injection vulnerabilities
- **Rate limiting validation** to prevent DoS attacks
- **Security headers audit** for compliance checking
- **Information disclosure scanning** for exposed sensitive files

# Technical Features
- ✅ Color-coded terminal output for easy result interpretation
- ✅ Detailed logging with timestamped results
- ✅ Organized result directories by test category
- ✅ Response time analysis for blind injection detection
- ✅ Multi-method HTTP request testing (GET, POST, PUT, DELETE, PATCH)
- ✅ URL encoding and advanced payload obfuscation
- ✅ Success/failure indicators with severity ratings

# 📦 Prerequisites

Before running the script, ensure you have the following installed:

```bash
# Required packages
- bash 4.0 or higher
- curl
- jq (for JSON/URL encoding)
- tee (for logging)

# Installation commands by OS
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install curl jq -y

# CentOS/RHEL
sudo yum install curl jq -y

# macOS
brew install curl jq
```

## 🚀 Installation

### Method 1: Clone Repository

```bash
git clone https://github.com/yourusername/waf-penetration-testing-suite.git
cd waf-penetration-testing-suite
chmod +x waf_penetration_test.sh
```

### Method 2: Direct Download

```bash
wget https://raw.githubusercontent.com/yourusername/waf-penetration-testing-suite/main/waf_penetration_test.sh
chmod +x waf_penetration_test.sh
```

## 🎯 Quick Start

### Basic Usage

```bash
# Test a domain with default settings
./waf_penetration_test.sh https://your-website.com

# Test with custom domain and save results
./waf_penetration_test.sh https://api.your-app.com

# Test local development environment
./waf_penetration_test.sh http://localhost:8000
```

### Example Output

```
=== WAF Penetration Testing Started at 2024-01-15 10:30:45 ===
Target: https://example.com

[✓] SQL Injection: BLOCKED (45/50 blocked - 90%)
[✓] XSS: BLOCKED (38/42 blocked - 90%)
[✗] Path Traversal: PASSED (12/25 blocked - 48%) - VULNERABLE
[✓] Command Injection: BLOCKED (28/30 blocked - 93%)
[!] Security Headers: WARNING - Missing headers: CSP, HSTS

==========================================
WAF Penetration Testing Complete
==========================================
⚠️  WARNING: 2 potential vulnerabilities detected!
```

## 🧪 Test Coverage

### 1. SQL Injection (SQLi)
- **50+ payloads** including:
  - Union-based queries
  - Boolean-based blind SQLi
  - Time-based blind SQLi
  - Stacked queries
  - Database fingerprinting
  - Evasion techniques (comment obfuscation, encoding)

### 2. Cross-Site Scripting (XSS)
- **42+ payloads** covering:
  - Reflected XSS
  - DOM-based XSS
  - Event handler injection
  - HTML5 vectors
  - Cookie theft attempts
  - Advanced obfuscation

### 3. Path Traversal & LFI
- **30+ payloads** including:
  - Basic traversal patterns
  - URL encoded variants
  - Double encoding
  - Null byte injection
  - Log poisoning attempts
  - PHP wrapper exploitation

### 4. Command Injection
- **35+ payloads** testing:
  - Basic command chaining
  - DNS exfiltration attempts
  - Time-based detection
  - Various shell operators
  - Encoded payloads

### 5. WAF Evasion Techniques
- **15+ advanced bypass methods**:
  - Case manipulation
  - Comment obfuscation
  - Mixed encoding
  - Null byte injection
  - Line break injection

### 6. Rate Limiting
- **50 rapid requests** to test:
  - Burst protection
  - Request throttling
  - HTTP 429/503 responses

### 7. Security Headers Audit
- **7 essential headers** checked:
  - X-Frame-Options
  - X-Content-Type-Options
  - X-XSS-Protection
  - Content-Security-Policy
  - Strict-Transport-Security
  - Referrer-Policy
  - Permissions-Policy

### 8. Information Disclosure
- **15+ sensitive paths** scanned:
  - Configuration files (.env, .git)
  - Backup files
  - System information
  - Framework detection

## 📊 Understanding Results

### Result Categories

| Symbol | Meaning | Description |
|--------|---------|-------------|
| ✓ | BLOCKED | WAF successfully blocked the attack |
| ✗ | PASSED | Attack succeeded (WAF failed to block) |
| ! | WARNING | Partial protection or missing configuration |
| ? | INFO | Informational message |

### Severity Levels

- **BLOCKED (>80%)**: Excellent WAF protection
- **WARNING (50-80%)**: Partial protection, needs improvement
- **PASSED (<50%)**: Vulnerable, immediate action required

### Result Files Structure

```
waf_test_results_20240115_103045/
├── sql_injection_results.txt
├── xss_results.txt
├── path_traversal_results.txt
├── cmd_injection_results.txt
├── evasion_results.txt
├── rate_limit_results.txt
├── security_headers.txt
├── info_disclosure_results.txt
├── successful_lfi.txt (if any)
├── time_based_cmd.txt (if any)
└── evasion_success.txt (if any)
```

## 🔧 Advanced Usage

### Testing Specific Endpoints

```bash
# Test API endpoint
./waf_penetration_test.sh https://api.example.com/v1

# Test login page specifically
./waf_penetration_test.sh https://example.com/login

# Test with custom port
./waf_penetration_test.sh https://example.com:8443
```

### Integration with Burp Suite

```bash
# Proxy through Burp Suite for deeper analysis
./waf_penetration_test.sh https://target.com --proxy http://127.0.0.1:8080
```

### Automation with CI/CD

```yaml
# GitHub Actions example
name: WAF Security Scan
on: [push, pull_request]
jobs:
  waf-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run WAF Penetration Test
        run: |
          chmod +x waf_penetration_test.sh
          ./waf_penetration_test.sh https://staging.example.com
```

### Scheduled Testing with Cron

```bash
# Run weekly security scans
# Add to crontab (crontab -e)
0 2 * * 0 /path/to/waf_penetration_test.sh https://example.com >> /var/log/waf_scan.log
```

## 📈 Interpreting WAF Effectiveness

### WAF Strength Rating

| Block Rate | Rating | Action Required |
|------------|--------|-----------------|
| 95-100% | 🟢 Excellent | Maintain and monitor |
| 80-94% | 🟡 Good | Review bypassed payloads |
| 50-79% | 🟠 Moderate | Tune WAF rules |
| <50% | 🔴 Weak | Urgent WAF reconfiguration needed |

### Common False Positives

The script may flag legitimate requests as attacks if:
- Your application uses special characters in user input
- You have custom API endpoints with unusual parameters
- Rate limiting is too aggressive

**Solution**: Whitelist specific endpoints or parameters in your WAF configuration.

## 🔍 Troubleshooting

### Common Issues

**Issue**: `jq: command not found`
```bash
# Solution: Install jq
sudo apt-get install jq -y  # Ubuntu/Debian
sudo yum install jq -y      # CentOS/RHEL
```

**Issue**: Permission denied when running script
```bash
# Solution: Make script executable
chmod +x waf_penetration_test.sh
```

**Issue**: Connection timeout errors
```bash
# Solution: Increase timeout in curl commands or check network
# Edit script and add --connect-timeout 30 to curl options
```

**Issue**: Rate limiting test shows all requests blocked
```bash
# Solution: Your IP might be temporarily banned
# Wait 5-10 minutes for rate limit to reset
# Or test from a different IP address
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Contribution Guidelines

- Add new attack payloads to appropriate arrays
- Maintain consistent code formatting
- Update documentation for new features
- Test thoroughly before submitting
- Follow OWASP testing standards

## 📝 License

Distributed under the MIT License. See `LICENSE` file for more information.

## ⚠️ Disclaimer

**IMPORTANT**: This tool is for **authorized security testing only**!

- ✅ **DO**: Test your own websites and applications
- ✅ **DO**: Obtain written permission before testing any system you don't own
- ❌ **DON'T**: Use this tool for unauthorized penetration testing
- ❌ **DON'T**: Attack systems without explicit permission

**Legal Notice**: Unauthorized testing may violate:
- Computer Fraud and Abuse Act (CFAA)
- GDPR and data protection laws
- Terms of Service agreements
- Local and international cybercrime laws

The authors assume no liability for misuse of this tool. Always ensure you have proper authorization before conducting security testing.

## 📚 Additional Resources

- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [WAF Evasion Techniques](https://owasp.org/www-community/attacks/xss/#waf-evasion)
- [Nginx Rate Limiting Documentation](https://nginx.org/en/docs/http/ngx_http_limit_req_module.html)
- [ModSecurity CRS Documentation](https://coreruleset.org/)

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/waf-penetration-testing-suite/issues)
- **Security Concerns**: security@yourdomain.com

---

**Made with ❤️ for the security community**

[Report Bug](https://github.com/yourusername/waf-penetration-testing-suite/issues) · [Request Feature](https://github.com/yourusername/waf-penetration-testing-suite/issues) · [Documentation](https://github.com/yourusername/waf-penetration-testing-suite/wiki)
```
