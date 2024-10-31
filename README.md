# AoTTG 2 Awesome Custom Logic Collection

## Structure:

- [Modes](./modes): Complete CL game modes.
- [Utils](./utils): Standalone modules for developing.

## Contributing

1. Fork this repository.

2. Create a new branch from main. 

```bash
git checkout -b type/name
```

> Branch naming:
> - Modes: `mode/mode_name`
> - Utils: `utils/util_name`

3. Add your mode/util.

>- Modes must include the following files:
>  - `mode_name.acl` with your Custom Logic (CL).
>  - `README.md` with a detailed description of how it works.
>  - `maps/map_name.txt` if it requires specific maps or you would like to suggest one.
>
>- Utils must include the following files:
>  - `code.acl` with your utility code.
>  - `README.md` with a description of the utility.

4. Commit your changes

```bash
git add .
git commit -m "Add [name] [type (mode/utility)]"
```

5. Open a Pull Request.