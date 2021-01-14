name: test
on: push
jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8]
    steps:
    - uses: actions/checkout@v2
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v2
      with:
        python-version: ${{ matrix.python-version }}
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
    - name: Build Index
      run: ./operator-index.py build -vvvv --tag-extension dev --opm-version $OPM_VERSION
    - name: Push to dev
      if: github.ref == 'refs/heads/develop'
      run: |
        docker login -u "$QUAY_USERNAME" -p "$QUAY_PASSWORD" quay.io && \
        ./operator-index.py push -vvvv --tag-extension dev --extra-tag develop --opm-version $OPM_VERSION && \
        ./operator-index.py push -vvvv --testing --opm-version $OPM_VERSION
    - name: Push to latest
      if: github.ref == 'refs/heads/main'
      run: |
        docker login -u "$QUAY_USERNAME" -p "$QUAY_PASSWORD" quay.io && \
        ./operator-index.py push -vvvv --extra-tag latest --build --opm-version $OPM_VERSION