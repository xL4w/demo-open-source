/**
 * Extracts the PR type from the given content of a pull request template.
 * The expected format in the template is: "PR Type: <type>\n".
 * @param {string} content - The content of the pull request template.
 * @returns {Object} - An object containing the PR type.
 */
const extractPRType = (content) => {
  const prTypeRegex = /PR Type: (.+?)\n/;
  const match = content.match(prTypeRegex);
  if (match) {
    return { prType: match[1] };
  } else {
    console.error('Failed to extract PR type from template content');
    return { prType: 'unknown' };
  }
};

module.exports = extractPRType;
