class QueryBuilder {
  final Map<String, String> _queryParameters = {};

  QueryBuilder addQuery(String key, String? value) {
    if (value == null || value == 'null' || value == '') {
      return this;
    }
    _queryParameters[key] = value;
    return this;
  }

  toMap() {
    return _queryParameters;
  }

  Uri toStrUri() {
    return Uri.parse("").replace(queryParameters: _queryParameters);
  }
}
