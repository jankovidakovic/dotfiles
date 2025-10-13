This is a copy-and-paste default Manjaro sway config taken from /etc/sway

So, instead of sourcing /etc/sway, we source from ./etc in user config.

Changelog:
- removed definition of $apply_background from definitions
- removed $apply_background from config.d/99-autostart-applications.conf
- removed call to $generate_background in config.d/90-enable-theme.conf

$apply_background is defined in definitions, which gets sourced first (etc definitions get sourced before user definitions)
$apply_background is set depending on the variable $background.
The problem is, at the time that $apply_background is defined, $background is still the default background
, and then, when $apply_background is ran at autostart, we get the default background.

This still doesn't explain why we cannot _again_ set the background later (in user space).
