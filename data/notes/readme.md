```jsonc
{
	// If null, then it bends to the current state of things.
	// When not null it uses what is put here.
	"pixelEnforcement": null,

	// The 1st and 2nd slots are the x and y offset.
	// The 3rd slot is an extra downscroll offset.
	// Just in case the y offset looks wrong on downscroll.
	"offsets": {
		"still": [0, 0, 0], // static animation
		"press": [0, 0, 0], // press animation
		"glow": [0, 0, 0], // confirm animation
		"note": [0, 0, 0] // note sprite
	},

	// If true, when a note with this skin is pressed, it will change the strum skin to the note skin.
	"canUpdateStrum": false,

	// If filled in, it will show a different splash skin.
	// Thought if the splash skin is the same name as the note skin then an override also occurs. Only if this is blank.
	"splashOverride": "",

	// This will change the scale of the texture.
	"scale": 0.7
}
```