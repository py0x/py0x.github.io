build:
	rm -rf docs && zola build && mv public docs && cp CNAME docs/CNAME

serve:
	zola serve
