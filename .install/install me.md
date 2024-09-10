## If using ox_inventory add this item to ox_inventory/data/items.lua

```
['stancekit'] = {
		label = "Stance Kit",
		weight = 30,
		stack = true,
		close = true
},
```

## If using esx_inventory or any SQL based inventory that uses the items table use this entry

```
INSERT INTO items VALUES ('stancekit', 'Stance Kit', 40, 0, 1)
```