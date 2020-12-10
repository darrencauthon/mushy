require 'sinatra'

require_relative 'mushy'

get '/' do
  %{
<html>
<head>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">
</head>
<body>
HEY
</body>
</html>
  }
end