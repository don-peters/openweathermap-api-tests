#!/bin/bash

# Advanced Newman Test Scripts
# Make sure to chmod +x this file after creating it

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COLLECTION_FILE="collection/openweathermap-collection.json"
ENVIRONMENT_FILE="environment/openweather-environment.json"
REPORTS_DIR="reports"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    # Check if Newman is installed
    if ! command -v newman &> /dev/null; then
        print_error "Newman is not installed. Please run: npm install -g newman"
        exit 1
    fi
    
    # Check if collection file exists
    if [[ ! -f "$COLLECTION_FILE" ]]; then
        print_error "Collection file not found: $COLLECTION_FILE"
        exit 1
    fi
    
    # Check if environment file exists
    if [[ ! -f "$ENVIRONMENT_FILE" ]]; then
        print_error "Environment file not found: $ENVIRONMENT_FILE"
        exit 1
    fi
    
    # Check for API key
    if [[ -z "$API_KEY" ]]; then
        print_warning "API_KEY environment variable not set"
        echo "Please export your API key: export API_KEY=your_actual_api_key"
        echo "Or it will be read from the environment file"
    fi
    
    print_success "All prerequisites met"
}

# Function to create reports directory
setup_reports() {
    print_status "Setting up reports directory..."
    mkdir -p "$REPORTS_DIR"
    print_success "Reports directory ready"
}

# Function to run basic tests
run_basic_tests() {
    print_status "Running basic API tests..."
    
    newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        ${API_KEY:+--env-var "API_KEY=$API_KEY"} \
        --reporters cli \
        --bail \
        --timeout 30000
    
    print_success "Basic tests completed"
}

# Function to run tests with detailed reporting
run_detailed_tests() {
    print_status "Running tests with detailed reporting..."
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local html_report="$REPORTS_DIR/api-test-report_$timestamp.html"
    local json_report="$REPORTS_DIR/api-test-results_$timestamp.json"
    
    newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        ${API_KEY:+--env-var "API_KEY=$API_KEY"} \
        --reporters cli,htmlextra,json \
        --reporter-htmlextra-export "$html_report" \
        --reporter-json-export "$json_report" \
        --timeout 30000
    
    print_success "Detailed reports generated:"
    echo "  HTML: $html_report"
    echo "  JSON: $json_report"
}

# Function to run performance tests
run_performance_tests() {
    print_status "Running performance-focused tests..."
    
    local perf_report="$REPORTS_DIR/performance_report_$(date +"%Y%m%d_%H%M%S").json"
    
    newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        ${API_KEY:+--env-var "API_KEY=$API_KEY"} \
        --reporters json \
        --reporter-json-export "$perf_report" \
        --timeout 10000 \
        --delay-request 100
    
    # Extract performance metrics
    if [[ -f "$perf_report" ]]; then
        print_success "Performance test completed"
        echo "Performance metrics:"
        
        # Use jq if available for better JSON parsing
        if command -v jq &> /dev/null; then
            echo "  Average response time: $(jq -r '.run.stats.responseTime.mean' "$perf_report")ms"
            echo "  Max response time: $(jq -r '.run.stats.responseTime.max' "$perf_report")ms"
            echo "  Total requests: $(jq -r '.run.stats.requests.total' "$perf_report")"
        else
            print_warning "Install jq for better performance metrics parsing"
        fi
    fi
}

# Function to run smoke tests (subset of critical tests)
run_smoke_tests() {
    print_status "Running smoke tests..."
    
    newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        ${API_KEY:+--env-var "API_KEY=$API_KEY"} \
        --folder "Health Check" \
        --reporters cli \
        --bail \
        --timeout 15000
    
    print_success "Smoke tests completed"
}

# Function to validate collection and environment files
validate_files() {
    print_status "Validating collection and environment files..."
    
    # Validate JSON syntax
    if ! python -m json.tool "$COLLECTION_FILE" > /dev/null 2>&1; then
        print_error "Invalid JSON in collection file: $COLLECTION_FILE"
        return 1
    fi
    
    if ! python -m json.tool "$ENVIRONMENT_FILE" > /dev/null 2>&1; then
        print_error "Invalid JSON in environment file: $ENVIRONMENT_FILE"
        return 1
    fi
    
    # Dry run to validate collection structure
    newman run "$COLLECTION_FILE" \
        --environment "$ENVIRONMENT_FILE" \
        --dry-run > /dev/null
    
    print_success "Files validation passed"
}

# Function to run security scan
run_security_scan() {
    print_status "Running security scan..."
    
    local issues_found=0
    
    # Check for potential secrets
    if grep -r "sk_\|pk_\|password\|secret" collection/ environment/ 2>/dev/null; then
        print_warning "Potential secrets found in files"
        issues_found=1
    fi
    
    # Check for hardcoded API keys
    if grep -r "appid.*[a-f0-9]\{32\}" collection/ environment/ 2>/dev/null; then
        print_warning "Potential hardcoded API keys found"
        issues_found=1
    fi
    
    # Check file permissions
    if [[ $(stat -c "%a" "$ENVIRONMENT_FILE" 2>/dev/null || stat -f "%A" "$ENVIRONMENT_FILE" 2>/dev/null) -gt 644 ]]; then
        print_warning "Environment file has overly permissive permissions"
        issues_found=1
    fi
    
    if [[ $issues_found -eq 0 ]]; then
        print_success "Security scan passed - no issues found"
    else
        print_warning "Security scan completed with warnings"
    fi
}

# Function to generate test summary
generate_summary() {
    print_status "Generating test summary..."
    
    local summary_file="$REPORTS_DIR/test_summary_$(date +"%Y%m%d_%H%M%S").md"
    
    cat > "$summary_file" << EOF
# Test Execution Summary

**Date**: $(date)
**Collection**: OpenWeatherMap API Tests
**Environment**: $(basename "$ENVIRONMENT_FILE" .json)

## Test Results

### Collection Structure
- Health Check Tests
- Current Weather API Tests  
- Geocoding Tests
- Error Handling Tests
- Performance Tests

### Key Metrics
- Total Requests: Available in detailed JSON reports
- Response Time Thresholds: < 1000ms for most endpoints
- Error Rate Target: 0% for valid requests

### Test Environment
- Base URL: https://api.openweathermap.org/data/2.5
- Geo URL: https://api.openweathermap.org/geo/1.0
- Test City: London
- API Version: Current Weather Data 2.5

### Notes
- All tests use metric units by default
- Error scenarios are tested with invalid inputs
- Performance thresholds are environment-dependent

EOF

    print_success "Test summary generated: $summary_file"
}

# Function to clean old reports
clean_reports() {
    print_status "Cleaning old report files..."
    
    # Keep only last 10 reports of each type
    find "$REPORTS_DIR" -name "*.html" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true
    find "$REPORTS_DIR" -name "*.json" -type f | sort -r | tail -n +11 | xargs rm -f 2>/dev/null || true
    find "$REPORTS_DIR" -name "*.md" -type f | sort -r | tail -n +6 | xargs rm -f 2>/dev/null || true
    
    print_success "Old reports cleaned"
}

# Main execution function
main() {
    local action="${1:-help}"
    
    case $action in
        "basic")
            check_prerequisites
            setup_reports
            run_basic_tests
            ;;
        "detailed"|"report")
            check_prerequisites
            setup_reports
            run_detailed_tests
            generate_summary
            ;;
        "performance"|"perf")
            check_prerequisites
            setup_reports
            run_performance_tests
            ;;
        "smoke")
            check_prerequisites
            setup_reports
            run_smoke_tests
            ;;
        "validate")
            validate_files
            ;;
        "security")
            run_security_scan
            ;;
        "full")
            check_prerequisites
            setup_reports
            validate_files
            run_security_scan
            run_detailed_tests
            run_performance_tests
            generate_summary
            clean_reports
            ;;
        "clean")
            clean_reports
            ;;
        "help"|*)
            echo "Usage: $0 {basic|detailed|performance|smoke|validate|security|full|clean|help}"
            echo ""
            echo "Commands:"
            echo "  basic       - Run basic API tests"
            echo "  detailed    - Run tests with HTML/JSON reporting"
            echo "  performance - Run performance-focused tests"
            echo "  smoke       - Run critical smoke tests only"
            echo "  validate    - Validate collection and environment files"
            echo "  security    - Run security scan on files"
            echo "  full        - Run complete test suite with all checks"
            echo "  clean       - Clean old report files"
            echo "  help        - Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  API_KEY     - OpenWeatherMap API key (required)"
            echo ""
            echo "Example:"
            echo "  export API_KEY=your_api_key_here"
            echo "  $0 detailed"
            ;;
    esac
}

# Execute main function with all arguments
main "$@"