# Domain Checker MCP

Use this as the desired contract if a dedicated domain-checker MCP is available or being built.

## Preferred capabilities

The MCP should expose at least:
- exact domain lookup
- batch lookup across TLDs
- registrar availability signal
- price or premium-domain signal
- DNS and HTTP reachability
- recent WHOIS or RDAP details

## Suggested tool shapes

### `lookup_domain`

Input:
- `domain`

Return:
- `domain`
- `available`
- `source`
- `registrar`
- `premium`
- `price`
- `dns_resolves`
- `http_status`
- `whois_summary`
- `checked_at`

### `lookup_name_across_tlds`

Input:
- `base_name`
- `tlds`

Return:
- list of `lookup_domain` results

### `suggest_domain_alternatives`

Input:
- `base_name`
- `strategy`

Return:
- nearby options such as prefix, suffix, compound, or category-bridge variants

## Fallback rule

If the MCP is not configured:
1. Use `scripts/check_domains.py`
2. Confirm important candidates with `whois`, `dig`, and browser checks
3. Confirm purchase reality at the registrar before making a final recommendation

Do not claim a domain is definitely available unless the registrar confirms it.
