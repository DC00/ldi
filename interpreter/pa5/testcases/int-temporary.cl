(* Weimer 2010 - a function in which many expressions involve the potential
   use of temporaries. *)
    
class Main inherits IO {
  main(): Object {
let a : Int,
b : Int,
c : Int,
d : Int,
e : Int,
f : Int,
g : Int in {
a <- in_int();
b <- in_int();
c <- in_int();
d <- in_int();
e <- in_int();
f <- in_int();
g <- in_int();
c <- d * c / e * g * 2;
out_int(c);
g <- d + e + c - b / 3;
out_int(g);
a <- e * g * e + a - a * e * c - 1;
out_int(a);
f <- g / c * f + 4;
out_int(f);
e <- a / d + b / d + b + 3;
out_int(e);
e <- f + d * c + g + 2;
out_int(e);
d <- d - e + d * f / c + g * e + 5;
out_int(d);
g <- g * c * e * c / e - 2;
out_int(g);
b <- c - f * c - c - 3;
out_int(b);
g <- d / b / d - d + 4;
out_int(g);
e <- g + g * b * d / a + a - g + 4;
out_int(e);
e <- f * f - d + 4;
out_int(e);
b <- f / a + a * d + b / g + f - 4;
out_int(b);
b <- d / b + e / f * c / b / 2;
out_int(b);
f <- d + b * g * a + e * d + 3;
out_int(f);
a <- g + e / a - 1;
out_int(a);
a <- f / c - d - d + 4;
out_int(a);
f <- d / a * e + g - f * 4;
out_int(f);
c <- f * a + f - a - g - a + b * 2;
out_int(c);
c <- b + e / g * a / g * d - 1;
out_int(c);
c <- b * b * g / d + b - e * 3;
out_int(c);
c <- b - a / c - f * g * e / 1;
out_int(c);
g <- d / e + b - e + 4;
out_int(g);
e <- b / e / g + a - f + c * 3;
out_int(e);
g <- g + g + b / c * g / e + d * 2;
out_int(g);
e <- b + e + b + a * e * b - d * 2;
out_int(e);
c <- a * b - a + g * c + a / e / 4;
out_int(c);
g <- c - g * a / f + e * 5;
out_int(g);
c <- e + c + g + b * 2;
out_int(c);
f <- d - c * b * f - 2;
out_int(f);
c <- c / e - a - a - c / a + 1;
out_int(c);
c <- f - d + b + 2;
out_int(c);
d <- b - d - g * e * b * 3;
out_int(d);
d <- f - d - e - e * 5;
out_int(d);
e <- e * f - f - b - f + 2;
out_int(e);
d <- d + d * c * g + b - 5;
out_int(d);
f <- e * a - c * g * c + 5;
out_int(f);
d <- g / g * g + 3;
out_int(d);
f <- g / d * e - 3;
out_int(f);
a <- c / e * c / e * f + e + 3;
out_int(a);
f <- b + e + f - g * e - b * g + 2;
out_int(f);
g <- g * e + g / e / 2;
out_int(g);
a <- c - a - c * a - 2;
out_int(a);
d <- g / f + a / e - b - b / f / 5;
out_int(d);
d <- d / d * d - e / 3;
out_int(d);
f <- b * g - d + a - b - g - g + 2;
out_int(f);
c <- c * d - e * 2;
out_int(c);
b <- d * f - f * c + 5;
out_int(b);
c <- a + f + c / d * 1;
out_int(c);
a <- f / g + b + g + c * c - a - 1;
out_int(a);
c <- a * e + e / c / b - 2;
out_int(c);
a <- f / d - f * g - g * d - 5;
out_int(a);
d <- e / a * g * c - b * b + 1;
out_int(d);
e <- c / c / d - a * a - g / d + 5;
out_int(e);
c <- c - e * e - g - e / d / g - 2;
out_int(c);
a <- b - c - e / 1;
out_int(a);
f <- e - a / e - 1;
out_int(f);
g <- a + d / a * a * f + f * 1;
out_int(g);
c <- e - f + g / f * g + f / 4;
out_int(c);
c <- b + b * b * 2;
out_int(c);
f <- g - c - a + g * f + a - 2;
out_int(f);
d <- f - a + e + e - 1;
out_int(d);
f <- g + a - a - 1;
out_int(f);
b <- f / d + e + f + 1;
out_int(b);
f <- f - a * e * c / 4;
out_int(f);
d <- a - g - g / 4;
out_int(d);
g <- g / g / b - e + b * b * f + 4;
out_int(g);
c <- b + c + e + 2;
out_int(c);
a <- b / c + b / e / b / e + 3;
out_int(a);
d <- c - a / f * g - d / c - c * 5;
out_int(d);
b <- a / b * c + 4;
out_int(b);
d <- b + f + c + d + c + b - c - 4;
out_int(d);
b <- g - c + d + b / a - 1;
out_int(b);
c <- g - e - c - b * c * e * 4;
out_int(c);
b <- b + a - a * d - b / 3;
out_int(b);
f <- b / f / c * 3;
out_int(f);
e <- c / c + b * e - f + e / 4;
out_int(e);
d <- e * d - f - e + c * g + d * 3;
out_int(d);
g <- c * e + b / b + b / 4;
out_int(g);
d <- c + a - c * d - g * 3;
out_int(d);
a <- d - b - b / 1;
out_int(a);
f <- e + b * g / d - 3;
out_int(f);
e <- c / b * f / f / d / g + a / 1;
out_int(e);
e <- f / c / b + c + 1;
out_int(e);
a <- a / g / e - f / b * g + 1;
out_int(a);
b <- g * e / d * 2;
out_int(b);
e <- e * c - f + d * g * f * d + 3;
out_int(e);
b <- c - a - f - b / 5;
out_int(b);
e <- e / c * a * 4;
out_int(e);
b <- a - a + d * e * b - d + f * 3;
out_int(b);
e <- a * f - b - a + b / 4;
out_int(e);
d <- c - g / f * g / 4;
out_int(d);
b <- d / c - f / g + e * a / 1;
out_int(b);
d <- g - d + d / c / a + d / f * 2;
out_int(d);
g <- d + f + g / f + d / g - b * 1;
out_int(g);
f <- f * b * e * d - f * c * d - 3;
out_int(f);
a <- a + f - e * f - a + 1;
out_int(a);
b <- b + f / a + 3;
out_int(b);
d <- e + b * b - 5;
out_int(d);
f <- f - f / b * g / b * 1;
out_int(f);
d <- d - d - c * g * b + 1;
out_int(d);
g <- g * b - e - e + g * e - e / 2;
out_int(g);
e <- b * a - d * g * c + 3;
out_int(e);
a <- a - b + g / a / d / 4;
out_int(a);
e <- d * f * g / b * 2;
out_int(e);
a <- c - e * g + b + a - 2;
out_int(a);
g <- e * a * g / 3;
out_int(g);
d <- b + f - d * g / f - b * a / 4;
out_int(d);
e <- d + d - e / d - g / b + 4;
out_int(e);
c <- f - d + e + a - 5;
out_int(c);
f <- g + g * d * 4;
out_int(f);
e <- g * d + d * 4;
out_int(e);
g <- f + d * e * e / e + 4;
out_int(g);
f <- b - c - g / 4;
out_int(f);
c <- c / c - a / 4;
out_int(c);
b <- c / b / e - 2;
out_int(b);
c <- c - e - c - b / c / e * d - 3;
out_int(c);
b <- d - f - g / d / 4;
out_int(b);
e <- c + e / a - c * f - 2;
out_int(e);
e <- e - e + e / d - b + f / f * 4;
out_int(e);
b <- d - e - g * f - b + d + 5;
out_int(b);
b <- f / c * e - b / 5;
out_int(b);
g <- c + e * e + 5;
out_int(g);
d <- d - g / d + g - b - b * 2;
out_int(d);
b <- c / c / a / g / f * f + 4;
out_int(b);
c <- d + e - a / e / d / g - 1;
out_int(c);
d <- f * c - f + 1;
out_int(d);
g <- f * b + d + d * 1;
out_int(g);
a <- b - e * f / a * e + b * b + 1;
out_int(a);
b <- a - g / f + e / g / 5;
out_int(b);
c <- d - b * g / b + b - d / 3;
out_int(c);
f <- g * f + d / a / b / 2;
out_int(f);
c <- b + g - g * c / f * a * c + 1;
out_int(c);
f <- c / g - d + 1;
out_int(f);
b <- c / e * f * 2;
out_int(b);
c <- g / e * d * d / e + 3;
out_int(c);
g <- c * a + f + d - g - g / a - 4;
out_int(g);
a <- d + g * d * d - 5;
out_int(a);
d <- c * f - g - e * b * c * g - 2;
out_int(d);
b <- f - f + b - b + c / g + 2;
out_int(b);
d <- d / g + c / e * a + 4;
out_int(d);
a <- c + g + g + c - g / d * 4;
out_int(a);
f <- e + a + b - f * 4;
out_int(f);
e <- c / c + c + f / 4;
out_int(e);
c <- b - b + c + g / g / f / 5;
out_int(c);
c <- f / b / g / 2;
out_int(c);
f <- e - d * f - 2;
out_int(f);
f <- f + c + g + d - 5;
out_int(f);
c <- c + g / d / d * 5;
out_int(c);
a <- e * e * a - d - f / g / 5;
out_int(a);
a <- a + c + e - e - e / d * d - 4;
out_int(a);
g <- b / c + g / c * 3;
out_int(g);
g <- f - a * d - f * a * 5;
out_int(g);
e <- f - f - b - 2;
out_int(e);
a <- a / f * c - g / e - b + d * 1;
out_int(a);
d <- c / d / b * d + e + a + f * 3;
out_int(d);
g <- g / f / f / a - g - b / 2;
out_int(g);
g <- d / e + d * g + 4;
out_int(g);
e <- e * a / d - f * a + c / c - 2;
out_int(e);
b <- e - f - c + c * b + g / 5;
out_int(b);
f <- b * c + a - f - e / d - 5;
out_int(f);
b <- g + c * b * c * e * e * 1;
out_int(b);
c <- a * d + f * c + a / d - g * 2;
out_int(c);
f <- a / c + f / d - b + b + 1;
out_int(f);
e <- a - e / c / 4;
out_int(e);
c <- c + c / d - 3;
out_int(c);
g <- g * g - f + a * e / f / e / 4;
out_int(g);
c <- a - a * c + 1;
out_int(c);
b <- b + b / c + g - g + 4;
out_int(b);
c <- a * a * g * 5;
out_int(c);
d <- c + d / a * d * f / b + f - 2;
out_int(d);
c <- e / g / e + b * 3;
out_int(c);
e <- e / a / b * a * f + a / a * 1;
out_int(e);
b <- e - e + f * a * a * b / b / 5;
out_int(b);
d <- g + c + g + a + g + e / f + 1;
out_int(d);
b <- c + c - c * g * g / e - 1;
out_int(b);
e <- c - b * c * 1;
out_int(e);
e <- g + c - g + e - 4;
out_int(e);
g <- f / b / e + 4;
out_int(g);
f <- f / a - e - 3;
out_int(f);
a <- d * b + d * b * 5;
out_int(a);
d <- f * c - a * g - f - 2;
out_int(d);
b <- b / d - b / d / g + g * f - 3;
out_int(b);
f <- c / g / d / a - 2;
out_int(f);
c <- b + a - e / d / 2;
out_int(c);
e <- c / e - g - c * 1;
out_int(e);
a <- e + e - c / e / a * c + a - 5;
out_int(a);
b <- b * e * d / d + e - g - 3;
out_int(b);
f <- d / a * d * b + e + g - 1;
out_int(f);
e <- b / c + g - e + a + b * 1;
out_int(e);
c <- c - f + d + d - f * a / 5;
out_int(c);
e <- d * d / d - c + 2;
out_int(e);
a <- f / d + a + g * 4;
out_int(a);
b <- a / d + g * 2;
out_int(b);
c <- a * c / e / d + 1;
out_int(c);
g <- c / g + d - d + 3;
out_int(g);
b <- a * g * c - 2;
out_int(b);
e <- b + g - b * g + f - e - e - 5;
out_int(e);
c <- g + a + g / e - 2;
out_int(c);
g <- a * c * e / 3;
out_int(g);
}
};
};
