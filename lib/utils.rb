
def is_integer?(str)
  begin
    Integer(str)
    return true
  rescue
    return false
  end
end

