pragma Ada_2022;

--  The first 54 chemical elements, as the data behind the Lists page.
package Demo.Elements with Pure is

   --  The element set is closed and small, so it is an enumeration and
   --  the table below is a total map from it; the atomic number is the
   --  position plus one.
   type Element is
     (Hydrogen, Helium, Lithium, Beryllium, Boron, Carbon, Nitrogen, Oxygen,
      Fluorine, Neon, Sodium, Magnesium, Aluminium, Silicon, Phosphorus,
      Sulfur, Chlorine, Argon, Potassium, Calcium, Scandium, Titanium,
      Vanadium, Chromium, Manganese, Iron, Cobalt, Nickel, Copper, Zinc,
      Gallium, Germanium, Arsenic, Selenium, Bromine, Krypton, Rubidium,
      Strontium, Yttrium, Zirconium, Niobium, Molybdenum, Technetium,
      Ruthenium, Rhodium, Palladium, Silver, Cadmium, Indium, Tin, Antimony,
      Tellurium, Iodine, Xenon);

   --  Also the vocabulary of the `category` widget property, so the names
   --  here are the CSS values: `Noble_Gas` is `[category="noble-gas"]`.
   type Category is
     (Alkali_Metal, Alkaline_Earth, Transition_Metal, Post_Transition,
      Metalloid, Nonmetal, Halogen, Noble_Gas);

   type Atomic_Mass is delta 0.001 digits 7;

   type Facts is record
      Symbol : String (1 .. 2);
      --  One-letter symbols are padded with a trailing space.
      Kind   : Category;
      Mass   : Atomic_Mass;
   end record;

   Table : constant array (Element) of Facts :=
     [Hydrogen   => ("H ", Nonmetal, 1.008),
      Helium     => ("He", Noble_Gas, 4.003),
      Lithium    => ("Li", Alkali_Metal, 6.94),
      Beryllium  => ("Be", Alkaline_Earth, 9.012),
      Boron      => ("B ", Metalloid, 10.81),
      Carbon     => ("C ", Nonmetal, 12.011),
      Nitrogen   => ("N ", Nonmetal, 14.007),
      Oxygen     => ("O ", Nonmetal, 15.999),
      Fluorine   => ("F ", Halogen, 18.998),
      Neon       => ("Ne", Noble_Gas, 20.180),
      Sodium     => ("Na", Alkali_Metal, 22.990),
      Magnesium  => ("Mg", Alkaline_Earth, 24.305),
      Aluminium  => ("Al", Post_Transition, 26.982),
      Silicon    => ("Si", Metalloid, 28.085),
      Phosphorus => ("P ", Nonmetal, 30.974),
      Sulfur     => ("S ", Nonmetal, 32.06),
      Chlorine   => ("Cl", Halogen, 35.45),
      Argon      => ("Ar", Noble_Gas, 39.948),
      Potassium  => ("K ", Alkali_Metal, 39.098),
      Calcium    => ("Ca", Alkaline_Earth, 40.078),
      Scandium   => ("Sc", Transition_Metal, 44.956),
      Titanium   => ("Ti", Transition_Metal, 47.867),
      Vanadium   => ("V ", Transition_Metal, 50.942),
      Chromium   => ("Cr", Transition_Metal, 51.996),
      Manganese  => ("Mn", Transition_Metal, 54.938),
      Iron       => ("Fe", Transition_Metal, 55.845),
      Cobalt     => ("Co", Transition_Metal, 58.933),
      Nickel     => ("Ni", Transition_Metal, 58.693),
      Copper     => ("Cu", Transition_Metal, 63.546),
      Zinc       => ("Zn", Transition_Metal, 65.38),
      Gallium    => ("Ga", Post_Transition, 69.723),
      Germanium  => ("Ge", Metalloid, 72.630),
      Arsenic    => ("As", Metalloid, 74.922),
      Selenium   => ("Se", Nonmetal, 78.971),
      Bromine    => ("Br", Halogen, 79.904),
      Krypton    => ("Kr", Noble_Gas, 83.798),
      Rubidium   => ("Rb", Alkali_Metal, 85.468),
      Strontium  => ("Sr", Alkaline_Earth, 87.62),
      Yttrium    => ("Y ", Transition_Metal, 88.906),
      Zirconium  => ("Zr", Transition_Metal, 91.224),
      Niobium    => ("Nb", Transition_Metal, 92.906),
      Molybdenum => ("Mo", Transition_Metal, 95.95),
      Technetium => ("Tc", Transition_Metal, 97.907),
      Ruthenium  => ("Ru", Transition_Metal, 101.07),
      Rhodium    => ("Rh", Transition_Metal, 102.906),
      Palladium  => ("Pd", Transition_Metal, 106.42),
      Silver     => ("Ag", Transition_Metal, 107.868),
      Cadmium    => ("Cd", Transition_Metal, 112.414),
      Indium     => ("In", Post_Transition, 114.818),
      Tin        => ("Sn", Post_Transition, 118.71),
      Antimony   => ("Sb", Metalloid, 121.76),
      Tellurium  => ("Te", Metalloid, 127.60),
      Iodine     => ("I ", Halogen, 126.904),
      Xenon      => ("Xe", Noble_Gas, 131.293)];

   subtype Atomic_Number is Positive range 1 .. Element'Pos (Element'Last) + 1;

   function Number (E : Element) return Atomic_Number is (Element'Pos (E) + 1);

   function Name (E : Element) return String;
   --  The display name: `Hydrogen` -> "Hydrogen".

   function Symbol (E : Element) return String;
   --  The symbol without padding: "H", "He".

   function Matches (E : Element; Query : String) return Boolean;
   --  True when `Query` is empty, equals the atomic number, or occurs in
   --  the name, the symbol or the category name, ignoring case.

   --  The elements matching a query, in atomic-number order. A sequence
   --  rather than a set: the list shows rows in this order and maps a
   --  clicked row index back to its element through it.
   type Selection is array (Positive range <>) of Element;

   function Filter (Query : String) return Selection;

end Demo.Elements;
