"""Normalize the user-authored 128x128 avatar pack for the Godot runtime."""

from pathlib import Path
from shutil import copy2

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "assets/source/user_avatar_pack"
AVATAR = ROOT / "assets/avatar"


def copy_png(source: Path, target: Path) -> None:
	target.parent.mkdir(parents=True, exist_ok=True)
	copy2(source, target)


def composite(target: Path, *sources: Path) -> None:
	result = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
	for source in sources:
		layer = Image.open(source).convert("RGBA")
		if layer.size != (128, 128):
			raise ValueError(f"{source} must be 128x128, got {layer.size}")
		result.alpha_composite(layer)
	target.parent.mkdir(parents=True, exist_ok=True)
	result.save(target)


def create_eye_layers(style: int, centers: tuple[tuple[int, int], tuple[int, int]]) -> None:
	folder = AVATAR / "eyes" / f"eye_{style:02d}"
	folder.mkdir(parents=True, exist_ok=True)
	eye_source = SOURCE / "face/eyes"

	closed_name = "olho_3_frchado.png" if style == 3 else f"olho_{style}_fechado.png"
	copy_png(eye_source / f"olho_{style}_aberto.png", folder / "sclera.png")
	copy_png(eye_source / f"olho_{style}_aberto.png", folder / "sclera_open.png")
	copy_png(eye_source / f"olho_{style}_semiaberto.png", folder / "sclera_half.png")
	copy_png(eye_source / closed_name, folder / "sclera_closed.png")

	iris = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
	iris_draw = ImageDraw.Draw(iris)
	pupil = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
	pupil_draw = ImageDraw.Draw(pupil)
	for x, y in centers:
		iris_draw.ellipse((x - 5, y - 7, x + 5, y + 7), fill=(215, 215, 215, 255))
		pupil_draw.ellipse((x - 2, y - 4, x + 2, y + 4), fill=(72, 72, 72, 255))
	iris.save(folder / "iris.png")
	pupil.save(folder / "pupil.png")


def main() -> None:
	base = SOURCE / "base"
	copy_png(base / "boneca base.png", AVATAR / "base/boneca_base_01.png")
	copy_png(base / "roupa de baixo.png", AVATAR / "base/underwear_01.png")

	# One finished body option exists today. Duplicate it into the three selector
	# slots so unfinished choices never drop the avatar back to placeholders.
	for option in range(1, 4):
		copy_png(base / "cabeça.png", AVATAR / f"heads/head_{option:02d}.png")
		copy_png(base / "corpo.png", AVATAR / f"torsos/torso_{option:02d}.png")
		composite(
			AVATAR / f"arms/arms_{option:02d}.png",
			base / "braço E.png",
			base / "braço D.png",
		)
		composite(
			AVATAR / f"legs/legs_{option:02d}.png",
			base / "perna E.png",
			base / "perna D.png",
		)

	eye_centers = {
		1: ((53, 37), (74, 37)),
		2: ((53, 39), (75, 39)),
		3: ((54, 37), (76, 37)),
		4: ((54, 39), (76, 39)),
	}
	for style, centers in eye_centers.items():
		create_eye_layers(style, centers)

	hair_source = SOURCE / "hair"
	for option in range(1, 4):
		copy_png(hair_source / f"cabelo_{option} tras.png", AVATAR / f"hair/hair_{option:02d}_back.png")
		copy_png(hair_source / f"cabelo_{option} frente.png", AVATAR / f"hair/hair_{option:02d}_front.png")

	copy_png(SOURCE / "face/mouth/boca_1_fechada1.png", AVATAR / "mouth/mouth_01_closed.png")

	clothes = SOURCE / "clothes"
	for option in range(1, 4):
		top_name = "roupa casual_1 parte de cima1.png" if option == 1 else f"roupa casual_{option} parte de cima.png"
		bottom_name = "roupa casual_1 parte de baixo1.png" if option == 1 else f"roupa casual_{option} parte de baixo.png"
		composite(
			AVATAR / f"clothing/sets/set_{option:02d}.png",
			clothes / bottom_name,
			clothes / top_name,
		)


if __name__ == "__main__":
	main()
