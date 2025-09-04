# OpenWeatherMap API Testing Collection

A comprehensive Postman collection for testing the OpenWeatherMap API with automated CI/CD pipeline using GitHub Actions and Newman.

## 🚀 Features

- **Comprehensive API Coverage**: Tests for current weather, geocoding, and error scenarios
- **Best Practices**: Proper test organization, environment variables, and error handling
- **Automated Testing**: GitHub Actions pipeline with Newman for CI/CD
- **Security Scanning**: Basic validation for hardcoded secrets
- **Detailed Reporting**: HTML and JSON reports with test results
- **Performance Testing**: Response time validation

## 📁 Project Structure

```
├── .github/
│   └── workflows/
│       └── api-tests.yml          # GitHub Actions workflow
├── collection/
│   └── openweathermap-collection.json  # Main Postman collection
├── environment/
│   └── openweather-environment.json    # Environment variables
├── reports/                       # Generated test reports (gitignored)
└── README.md                      # This file
```

## 🔧 Setup Instructions

### 1. Get OpenWeatherMap API Key

1. Sign up at [OpenWeatherMap](https://openweathermap.org/api)
2. Generate a free API key
3. Note: Free tier allows 1,000 calls/day

### 2. Environment Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd openweathermap-api-tests
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   ```bash
   # Copy the example file
   cp .env.example .env
   
   # Edit .env and add your API key
   echo "OPENWEATHER_API_KEY=your_actual_api_key_here" > .env
   ```

4. **Run tests**:
   ```bash
   # Export the environment variable
   source .env
   export OPENWEATHER_API_KEY
   
   # Run tests
   npm run test
   ```

### 3. Postman Setup (Optional)

1. **Import Collection**:
   - Open Postman
   - Import `collections/openweather_collection.json`

2. **Import Environment**:
   - Import `environments/environment_file.json`
   - Update the `API_KEY` variable with your actual API key

3. **Run Tests**:
   - Select the environment
   - Run the collection or individual requests

### 4. GitHub Repository Setup

1. **Fork/Clone this repository**

2. **Add GitHub Secret**:
   - Go to repository Settings → Secrets and variables → Actions
   - Add a new secret: `OPENWEATHER_API_KEY` with your API key

3. **Enable GitHub Actions**:
   - The workflow will run automatically on push/PR
   - You can also trigger it manually from the Actions tab

### 4. Local Newman Setup

Install Newman globally:
```bash
npm install -g newman newman-reporter-htmlextra
```

Run tests locally:
```bash
# Basic run
newman run collection/openweathermap-collection.json \
  --environment environment/openweather-environment.json \
  --env-var "API_KEY=your_actual_api_key"

# With detailed reporting
newman run collection/openweathermap-collection.json \
  --environment environment/openweather-environment.json \
  --env-var "API_KEY=your_actual_api_key" \
  --reporters cli,htmlextra \
  --reporter-htmlextra-export reports/test-report.html
```

## 🧪 Test Scenarios

### Health Check
- Basic API connectivity test
- Response time validation
- Content-type verification

### Current Weather API
- **By City Name**: Tests city-based weather retrieval
- **By Coordinates**: Tests coordinate-based weather retrieval
- **Schema Validation**: Ensures response structure is correct
- **Data Validation**: Validates temperature ranges and coordinate bounds

### Geocoding API
- **Direct Geocoding**: Convert city names to coordinates
- **Response Validation**: Ensures proper coordinate format
- **Array Handling**: Tests multiple location results

### Error Handling
- **Invalid API Key**: Tests 401 authentication errors
- **City Not Found**: Tests 404 not found scenarios  
- **Invalid Parameters**: Tests 400 bad request handling

### Performance Testing
- Response time thresholds
- Performance logging and monitoring

## 📊 Test Reports

The GitHub Actions workflow generates several types of reports:

1. **Console Output**: Real-time test results in the Actions log
2. **HTML Report**: Detailed visual report with charts and graphs
3. **JSON Report**: Machine-readable results for further processing
4. **PR Comments**: Automatic test summary comments on pull requests

## 🔒 Security Best Practices

### Environment Variables
- API keys are stored as environment variables
- Never commit actual API keys to version control
- Use GitHub Secrets for CI/CD pipelines

### Collection Security
- The collection uses `{{API_KEY}}` placeholders
- Authentication is configured at collection level
- Automated scanning for hardcoded secrets

### API Rate Limiting
- Tests respect OpenWeatherMap's rate limits
- Timeout configurations prevent hanging requests
- Error handling for rate limit scenarios

## 🚀 Advanced Usage

### Custom Test Cities
Update the environment variables to test different locations:
```json
{
  "key": "testCity",
  "value": "Paris"
}
```

### Additional Weather Parameters
Extend requests with more parameters:
- `units`: metric, imperial, kelvin
- `lang`: language for weather descriptions
- `mode`: json, xml, html

### Chaining Requests
The collection demonstrates variable passing between requests:
- Geocoding API results feed into weather API
- Dynamic coordinate extraction and reuse

### Custom Assertions
Add your own test cases:
```javascript
pm.test("Temperature is reasonable for season", function () {
    const temp = pm.response.json().main.temp;
    // Add seasonal logic here
    pm.expect(temp).to.be.within(-50, 50); // Celsius range
});
```

## 🔄 CI/CD Pipeline

The GitHub Actions workflow includes:

### Triggers
- **Push** to main/develop branches
- **Pull Requests** to main branch  
- **Scheduled** runs (daily at 6 AM UTC)
- **Manual** workflow dispatch

### Jobs
1. **API Tests**: Run the complete test suite
2. **Security Scan**: Validate for secrets and JSON format
3. **Artifact Upload**: Save test reports
4. **PR Comments**: Post results to pull requests

### Failure Handling
- Tests fail fast on critical errors
- Reports are generated even on failures
- Security issues block the pipeline

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your tests or improvements
4. Ensure all tests pass locally
5. Submit a pull request

### Adding New Tests
- Follow the existing test structure
- Use descriptive test names
- Include both positive and negative scenarios
- Add appropriate assertions for data validation

### Environment Variables
- Use collection/environment variables for reusable values
- Document any new variables