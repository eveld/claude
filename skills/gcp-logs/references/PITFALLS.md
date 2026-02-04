# Common Pitfalls and Solutions

Avoid these common mistakes when querying GCP logs.

## Escaping and Quoting Issues

```bash
# ❌ WRONG - Shell interprets special characters
gcloud logging read jsonPayload.message=~"error" --limit=10

# ✅ CORRECT - Single quotes protect the filter
gcloud logging read 'jsonPayload.message=~"error"' --limit=10

# ❌ WRONG - Complex nested conditions cause escaping issues
gcloud logging read 'field1="val1" AND (field2="val2" OR field3="val3")' --limit=10

# ✅ BETTER - Use two-stage with jq for complex logic
gcloud logging read 'field1="val1"' --limit=100 --format=json | \
  jq '.[] | select(.field2 == "val2" or .field3 == "val3")'
```

**Rule**: Always single-quote filter strings. For complex logic, use two-stage filtering with jq.

## Time Range Performance

```bash
# ❌ SLOW - Very broad time range
gcloud logging read 'jsonPayload.message="error" AND timestamp>="2025-01-01T00:00:00Z"' --limit=1000

# ✅ FASTER - Narrow time window (1-2 hours for recent data)
gcloud logging read 'jsonPayload.message="error" AND timestamp>="2025-11-20T15:00:00Z" AND timestamp<="2025-11-20T16:00:00Z"' --limit=1000

# ✅ BEST - Start narrow, expand if needed
# 1. Check last hour
# 2. If no results, expand to last 24 hours
# 3. If still no results, check if ANY logs exist in broader range
```

**Rule**: Start with 1-2 hour windows. Expand only if necessary.

## Deep Nesting Failures

```bash
# ❌ OFTEN FAILS - Complex nested conditions in gcloud filter
gcloud logging read 'jsonPayload.deeply.nested.field="value" AND jsonPayload.other.nested="val2"' --limit=10

# ✅ USE TWO-STAGE - Query broad, filter with jq
gcloud logging read 'jsonPayload.message="api request"' --format=json --limit=100 | \
  jq '.[] | select(.jsonPayload.deeply.nested.field == "value" and .jsonPayload.other.nested == "val2")'
```

**Rule**: For deeply nested fields (>2 levels) or complex boolean logic, use two-stage filtering.

## Missing Data vs Bad Query

```bash
# ❌ UNCLEAR - Did query fail or is there no data?
gcloud logging read 'very-specific-filter' --limit=10
# Returns empty... but why?

# ✅ VERIFY DATA EXISTS - Check broader query first
# Step 1: Check if ANY logs exist in time range
gcloud logging read 'timestamp>="2025-12-24T10:00:00Z"' --limit=10

# Step 2: Check if service logs exist
gcloud logging read 'resource.labels.container_name="service-b"' --limit=10

# Step 3: Add specific filters incrementally
gcloud logging read 'resource.labels.container_name="service-b" AND severity>=ERROR' --limit=10
```

**Rule**: Start broad, add filters incrementally. Verify data exists before adding complex conditions.

## Large Result Sets

```bash
# ❌ OVERWHELMING - Raw output to terminal
gcloud logging read 'severity>=ERROR' --limit=5000 --format=json
# (5000 log entries flood your screen)

# ✅ SAVE TO FILE - Analyze separately
gcloud logging read 'severity>=ERROR' --limit=5000 --format=json > /tmp/errors-$(date +%Y%m%d-%H%M%S).json

# Then analyze
cat /tmp/errors-*.json | jq '.[] | select(.severity=="CRITICAL")'
cat /tmp/errors-*.json | jq '.[] | .jsonPayload.message' | sort | uniq -c
```

**Rule**: For >100 entries, save to `/tmp/` file for analysis.
