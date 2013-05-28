
This folder contains a snapshot of the 'angelfont' set of classes by Robin Beaker, along with simple wrapper classes so they can be treated as Congo Sprites. A version of the angelfont code is also distributed along with the Monkey source code. It is licensed under the same terms as Monkey.

The angelfont code does not generate monkeydoc documentation.

Note, added check at line 161 to avoid crash if kern nodes is null:
	If nodes Then ' [BRS] bug fix if nodes is null. I get this on certain fonts