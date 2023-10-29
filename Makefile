.ONESHELL:
ENV_PREFIX=$(shell python -c "if __import__('pathlib').Path('.venv/bin/pip').exists(): print('.venv/bin/')")
USING_POETRY=$(shell grep "tool.poetry" pyproject.toml && echo "yes")

.PHONY: install-poetry
install-poetry:		
	curl -sSL https://install.python-poetry.org | python3 -	

.PHONY: fmt
fmt:
	black application_profiles/
	black tests/

.PHONY: install
install:
	pip install poetry
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
	mkdir reports || true
	safety check -r requirements.txt --output screen

.PHONY: build
build:			## Build locally the python artifact
	python setup.py sdist bdist_wheel

.PHONY: upload
upload:
	python -m twine upload --repository deliverlitics-registry-python dist/*