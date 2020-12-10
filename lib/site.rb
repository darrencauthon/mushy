require 'sinatra'

require_relative 'mushy'

get '/' do
  %{
<html>
<head>
</head>
<body>
HEY
</body>
</html>
  }
end