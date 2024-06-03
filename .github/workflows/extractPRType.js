function extractPRType(templateContent) {
    // Implement your logic to parse the template content (e.g., using regular expressions)
    // This example looks for lines containing "[x] **applications**" or "[x] **infrastructure**"
    const regex = /\[x\] \*\*(\w+)\*\*/g;
    const matches = templateContent.match(regex);
    let prType = null;
    if (matches) {
      prType = matches[0].split("**")[1].toLowerCase(); // Extract the matched type (applications or infrastructure)
    }
    return { prType }; // Return an object with the extracted PR type (if any)
  }
  