set -B                  # enable brace expansion
for i in {1..100}; do
  curl -s -k 'POST' \
  -u :"your-azdo-token-here" \
  -H "Content-Type: application/json"  \
  -d '{ "comments": [ { "parentCommentId": 0, "content": "Should we add a comment about what this value means?", "commentType": 1 } ], "status": 1 }' \
  'your-azdo-url-here'
done