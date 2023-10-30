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
clean:
	@python setup.py clean --build --dist --eggs --pycache
	@rm -rf reports/ || true
	@rm -f .coverage || true

.PHONY: lint
lint:
	mkdir reports || true
	pylint --output-format=json:reports/lint-report.json --reports=y --exit-zero application_profiles/*.py

.PHONY: test
test:
	mkdir reports || true
	poetry run pytest --cov=application_profiles --junitxml=reports/junit.xml tests

.PHONY: security
security:
	poetry lock
	poetry export --without-hashes -f requirements.txt
	mkdir reports || true
	poetry run safety check -r requirements.txt --output screen
	rm -rf requirements.txt || true

.PHONY: publish-prerelease
publish-prerelease:
	poetry version prerelease
	poetry config repositories.test-pypi https://test.pypi.org/legacy/
	poetry build --format sdist
	poetry publish --repository test-pypi -u ${PYPI_USERNAME} -p ${PYPI_PASSWORD}

.PHONY: publish-release
publish-release:
	poetry version minor
	poetry config repositories.pypi https://pypi.org/legacy/
	poetry config pypi-token.pypi ${PYPI_PASSWORD}
	poetry build --format sdist
	poetry publish --repository test-pypi
