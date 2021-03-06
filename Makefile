
export PYTHONPATH=.

name=$(shell grep name= setup.py | awk -F "'" '{print $$2}')
version=$(shell grep version= setup.py | awk -F "'" '{print $$2}')

all: lint test

docs: build_docs

build_docs:
	cd docs && make html
	pandoc -t rst README.md | sed -e '1,1s/^[^\\]*//' -e '2d' > README.rst

lint:
	pylint python_jwt test bench

test: run_test

run_test:
	./test/run/run_pyvows.py -v test

coverage: run_coverage

run_coverage:
	./test/run/run_coverage.py run --source=python_jwt -m test.run.run_pyvows -v test
	./test/run/run_coverage.py html --fail-under=85 -d coverage/html
	./test/run/run_coverage.py xml --fail-under=85 -o coverage/coverage.xml

bench: run_bench

run_bench:
	for b in ./bench/*_bench.py; do $$b; done

bench_gfm: 
	for b in ./bench/*_bench.py; do $$b --gfm; done

node_deps:
	mkdir -p node_modules && npm install --python=python2.7 jsjws sinon

dist: make_dist

make_dist:
	python setup.py sdist
	python setup.py bdist_wheel --universal

upload:
	twine upload dist/$(name)-$(version)*
