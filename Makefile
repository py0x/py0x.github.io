build:
	rm -rf docs && zola build && mv public docs

serve:
	zola serve
