
.PHONY: test

## ====
## Mush
## ====

.DEFAULT:
	@mush $@

## ====
## Test
## ====

test:
	@bin/bats test/r.bats
