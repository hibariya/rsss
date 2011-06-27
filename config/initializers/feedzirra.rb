class Feedzirra::Parser::RSSEntry
  elements :'dc:subject', as: :subjects
end

class Feedzirra::Parser::AtomEntry
  elements :'dc:subject', as: :subjects
end

class Feedzirra::Parser::AtomFeedBurnerEntry
  elements :'dc:subject', as: :subjects
end
