.DELETE_ON_ERROR:
.PHONY: test clean announce

JQ = jq

UNNEST_TESTS = object only-array small-array
UNNEST_TEST_RUNS = $(UNNEST_TESTS:%=test/.test-unnest-%)

CSV_TESTS = object only-array small-array jq-issues
CSV_TEST_RUNS = $(CSV_TESTS:%=test/.test-csv-%)

TEST_RUNS = $(UNNEST_TEST_RUNS) $(CSV_TEST_RUNS)
.INTERMEDIATE: $(TEST_RUNS)

test: announce $(TEST_RUNS)
	@echo
	@echo "TEST PASS"
	@echo

announce:
	@echo
	@echo "============================================================="
	@echo "TESTING: $(TEST_RUNS)"
	@echo

# Check test outputs
test/.test-unnest-%: test/.out-unnest-%.json test/test-unnest-%.jq
	@echo ".... validating unnested json: $*"
	@$(JQ) -e -f test/test-unnest-$*.jq $< > $@

test/.test-csv-%: test/.out-csv-%.csv test/test-csv-%.sh
	@echo ".... validating csv: $*"
	@$(SHELL) -e test/test-csv-$*.sh $< > $@

# Do test runs
test/.out-unnest-%.json: test/fixture-%.json
	@echo ".. unnesting json: $*"
	@$(JQ) --stream --slurp -f unnest.jq $< > $@

test/.out-csv-%.csv: test/.out-unnest-%.json
	@echo ".. converting to csv: $*"
	@$(JQ) -r --slurp -f json-to-csv.jq $< > $@

clean:
	$(RM) test/.out* test/.test*
