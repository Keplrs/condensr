class Condensr
  def self.extract_file_name(url)
    url.rpartition('/').last.tr('[|&;$%@"<>''()+,]', '')
  end

  def self.expand_file_path(file_path)
    File.expand_path("../#{file_path}", File.dirname(__FILE__))
  end
end
