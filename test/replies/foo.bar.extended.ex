case params do
  %{"key" => 1} -> "response"
  %{"key" => 2} -> "response2"
  _ -> %{"error": "unknown"}
end
