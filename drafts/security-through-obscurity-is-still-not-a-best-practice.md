---
Title: TBD
Author: Sami Samhuri
Date: 20th August, 2017
Timestamp: 1503246688
Tags: rails, security
---

A common way to configure a Rails server for different deployment environments is to use environment variables. This is a good practice as described by [The Twelve-Factor App][12factor] and can be applied to any server framework in any language running on a Unix OS. It keeps such secrets out of your code repository which is good, and it also makes it easy to customize your application for different environments. It's a pretty solid technique.

[12factor]: https://12factor.net

However there is a drawback to this for some types of configuration. For example, if you use AWS and put an access ID and secret key in your environment then any 3rd-party library you include and any process you [fork][] or [spawn][] can peer into the environment and steal all of your secrets. This is certainly a possible attack vector but we all have control over which libraries we choose to use and which processes we decide to fork or spawn. We can all use our judgement on these points and audit code that we include. That may be a bit theoretical because it would take a lot of resources for a small team to audit, say, Rails, but it is possible.

Rails 5.1 has introduced [a way to include encrypted secrets directly in your repository][rails-secrets], but without including the key itself so that if your repository is compromised the attacker still cannot decrypt the secrets. So far this sounds good but there's a pretty big flaw here in that you have to provide the key to your application somehow. If you're starting to see the [similarities to DRM][drm] here then you probably know where this is going.

[rails-secrets]: https://www.engineyard.com/blog/encrypted-rails-secrets-on-rails-5.1
[drm]: https://techliberation.com/2007/04/13/felten-on-drm-and-security-through-obscurity/

The recommended methods of providing the decryption key to your application are to pass it in via the environment, or in a file on disk that you copy to your server but don't commit to your repo.

**You cannot have any reasonable expectation that an attacker with access to your Rails app or environment in any way will be unable to steal or decrypt your secrets when your key is made available via the environment or a file on disk.**

If you provide the key via an environment variable then you're basically back where we started. 3rd party code running in the Rails process can read your key out of the environment and decrypt the secrets file on disk, and any process you [spawn][] or [fork][] will inherit the environment and can do the same. In fact if a gem you use knows it's running in Rails app it can trivially just use `Rails::Application#secrets` as easily as you can in your own code. You really aren't gaining much here.

[spawn]: https://linux.die.net/man/3/posix_spawn
[fork]: https://linux.die.net/man/3/fork

If you provide the key via a file on disk then it's even worse! Any process on the entire machine that has read access to your code can read the key and decrypt your secrets. Please, don't bother doing this in the name of security. So far the only thing accomplished by using this encryption scheme is to obscure your secrets a little bit. It's pretty trivial for an attacker to get around this obfuscation.

I'm not a security expert but I can think of one way to further mitigate attacks: Rails could read your secret from the environment and then clear the environment variable so spawned/forked child processes can no longer read the key.

Providing the decryption key necessarily makes it impossible for you to truly protect your secrets from an attacker. It's security through obscurity and it's still not a best practice. It's a false sense of security. Ultimately you need to trust the code you run on your server if you have secrets on it but you can't trust the code then you absolutely should not be running it if you really require secrecy.

I'm not trying to spell out doom and gloom here. Just be aware of the fact that you're pushing the problem around and not solving it outright. For most of us that's probably good enough, but then ask yourself how much you gain by using a complicated encryption scheme instead of just configuring stuff in environment variables or `secrets.yml` in the first place. Playing cat and mouse games with an attacker who has access to the key is futile unless you're willing to invest a lot more effort into hiding things than they are willing to invest into finding them. Be aware of the trade-offs you're making before putting effort into trying to hide things that are incredibly difficult to actually hide.
