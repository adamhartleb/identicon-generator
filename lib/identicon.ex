defmodule Identicon do
  import Identicon.Image

  def main(input) do
    input 
    |> hash_input
    |> pick_color
    |> create_grid
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def pick_color(image) do
    [r, g, b | _list] = image.hex
    %Identicon.Image{image | color: {r, g, b}}
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  def create_grid(image) do
    {hex, color} = {image.hex, image.color}
    hex = Enum.chunk(hex, 3)
    |> Enum.map(&mirror_rows/1)
    |> List.flatten
    {hex, color}
  end

  def mirror_rows(chunked_hex) do
    [first, second | _tail] =  chunked_hex
    chunked_hex ++ [second, first]
  end
  
  def build_pixel_map({grid, color}) do

    pixel_grid = Enum.filter(grid, fn(x) ->
      rem(x, 2) == 0
    end)
    |> Enum.with_index
    |> Enum.map(fn({_useless, index}) ->
        horizontal = rem(index, 5) * 50
        vertical = div(index, 5) * 50
        top_left = {horizontal, vertical}
        bottom_right = {horizontal + 50, vertical + 50}

        {top_left, bottom_right}
    end)
    IO.puts(pixel_grid)
    {pixel_grid, color}
  end

  def draw_image({pixel_map, color}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each(pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end)

    :egd.render(image)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end
end
