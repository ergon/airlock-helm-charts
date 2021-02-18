helm-docs:
	@echo --- Generating Chart READMEs
	@docker run --rm -v $$(pwd):/helm-docs -u $$(id -u) jnorwood/helm-docs:v1.5.0
