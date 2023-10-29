.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")
USING_POETRY=$(shell grep "tool.poetry" pyproject.toml && echo "yes")

.PHONY: install-poetry
install-poetry:		
	pip install poetry

.PHONY: fmt
fmt:
	black application_profiles/
	black tests/

.PHONY: install
install:
	poetry config virtualenvs.in-project true
	poetry install
	echo "Run 'poetry shell' to enable the environment"

.PHONY: remove-env
remove-env:
	rm -rf .venv && poetry env remove --all

.PHONY: clean
clean:			## Clean unused files.
	@python setup.py clean --build --dist --eggs --pycache
	@rm -rf reports/ || true
	@rm -f .coverage || true

.PHONY: lint
lint:			## Run pylint.
	mkdir reports || true
	pylint --output-format=json:reports/lint-report.json --reports=y --exit-zero application_profiles/*.py

.PHONY: test
test:			## Run tests and coverage
	mkdir reports || true
	pytest --junitxml=reports/junit.xml tests

.PHONY: security
security:		## Run dependency security check
	poetry export --without-hashes -f requirements.txt | safety check --full-report --stdin
	mkdir reports || true
	safety check -r requirements.txt --output screen
	rm -rf requirements.txt

.PHONY: build
build:			## Build locally the python artifact
	python setup.py sdist bdist_wheel

.PHONY: upload
upload:
	python -m twine upload --repository deliverlitics-registry-python dist/*