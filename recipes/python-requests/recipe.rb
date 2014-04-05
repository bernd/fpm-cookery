class PythonRequests < FPM::Cookery::PythonRecipe
  homepage "http://python-requests.org"
  name "requests"
  build_depends ["python-setuptools"]
  depends ["python"]
  version "2.2.1"
end
