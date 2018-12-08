require 'json'

=begin
	Processing rules:
	- drafts/*.md: render the draft
	- posts/*.md: render the post, archive, index, and date indexes (yearly, monthly)
	- templates/*: render everything
	- public/*: copy to the public bucket
	- anything else: warning or error?

	Public bucket structure:
	- index.html
	- feed.xml
	- feed.json
	- archive/index.html
	- posts/yyyy/index.html
	- posts/yyyy/mm/{slug}.html
=end

def handler(event:, context:)
  {
    event: JSON.generate(event),
    context: JSON.generate({ context: context.inspect }),
  }
end
