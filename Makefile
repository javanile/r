
## ====
## Mush
## ====

.DEFAULT:
	@mush $@

## ====
## Test
## ====

test:
	@mush run delete -s -f server test-server
	@mush run add server test-server
