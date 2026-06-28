CHARTS_DIR=charts
DOCS_DIR=docs
REPO_URL=https://jaxxstorm.github.io/border0-helm-charts

.PHONY: package index clean

package:
	@echo "Packaging all charts in $(CHARTS_DIR)..."
	@mkdir -p $(DOCS_DIR)
	@for chart in $(CHARTS_DIR)/*/Chart.yaml; do \
		chart_dir=$$(dirname $$chart); \
		echo "Packaging $$chart_dir..."; \
		helm package $$chart_dir --destination $(DOCS_DIR); \
	done

index: package
	@echo "Generating Helm repo index at $(DOCS_DIR)..."
	helm repo index $(DOCS_DIR) --url $(REPO_URL)

clean:
	@echo "Cleaning up packaged charts and index..."
	rm -f $(DOCS_DIR)/*.tgz
	rm -f $(DOCS_DIR)/index.yaml
