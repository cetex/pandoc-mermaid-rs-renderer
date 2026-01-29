IMAGE_NAME = pandoc-mmdr

.PHONY: build example clean

# Build the Docker image
build:
	docker build --target pandoc-mmdr -t $(IMAGE_NAME) .

# Generate the example PDF
example: build
	docker run --rm \
		-v "$$(pwd):/data" \
		-u $$(id -u):$$(id -g) \
		$(IMAGE_NAME) \
		--toc --toc-depth=2 \
		--template eisvogel \
		--pdf-engine=xelatex \
		--lua-filter mermaid-mmdr.lua \
		examples/example.md \
		-o examples/example.pdf

clean:
	rm -f examples/example.pdf
	docker rmi $(IMAGE_NAME)
