-- migrate:up

create extension if not exists "uuid-ossp";

create schema kitchen_api_data;

create table kitchen_api_data.recipes
(
    id         uuid primary key default uuid_generate_v4(),
    title text,
    description text,
    category  text
);

create table kitchen_api_data.ingredients
(
    id          uuid primary key default uuid_generate_v4(),
    title text,
    category  text,
    price int
);

create table kitchen_api_data.recipes_ingredients
(
    recipe_id uuid references kitchen_api_data.recipes on delete cascade,
    ingredient_id  uuid references kitchen_api_data.ingredients,
    primary key (recipe_id, ingredient_id)
);

create table kitchen_api_data.comments
(
    id          uuid primary key default uuid_generate_v4(),
    text text,
    published_on  date default now(),
    recipe_id uuid references kitchen_api_data.recipes on delete cascade
);

insert into kitchen_api_data.recipes(title, description, category)
values ('Борщ', 'Старинный рецепт борща прямиком из Древней Руси', 'супы'),
       ('Блины', 'Рецепт блинов', 'мучное'),
       ('Пепперони', 'Рецепт итальянской пиццы пепперони', 'итальянская кухня'),
       ('Карбонара', 'Рецепт классической итальянской пасты "Карбонара"', 'итальянская кухня');

insert into kitchen_api_data.ingredients(title, category, price)
values ('Картофель', 'овощи', 5),
       ('Пармезан', 'молочные продукты', 100),
       ('Пшеничная мука', 'муки', 100),
       ('Оливковое Масло', 'масла', 120),
       ('Сливочное Масло', 'масла', 120),
       ('Спагетти', 'мучное', 60),
       ('Сахар', 'крупы', 30),
       ('Колбаса', 'мясо', 120),
       ('Говядина', 'мясо', 150),
       ('Куриное яйцо', 'яйца', 150),
       ('Свекла', 'овощи', 120);

insert into kitchen_api_data.recipes_ingredients(recipe_id, ingredient_id)
values
    ((select id from kitchen_api_data.recipes where title = 'Борщ'),
     (select id from kitchen_api_data.ingredients where title = 'Свекла')),
    ((select id from kitchen_api_data.recipes where title = 'Борщ'),
     (select id from kitchen_api_data.ingredients where title = 'Картофель')),
    ((select id from kitchen_api_data.recipes where title = 'Борщ'),
     (select id from kitchen_api_data.ingredients where title = 'Говядина')),
    ((select id from kitchen_api_data.recipes where title = 'Блины'),
     (select id from kitchen_api_data.ingredients where title = 'Пшеничная мука')),
    ((select id from kitchen_api_data.recipes where title = 'Блины'),
     (select id from kitchen_api_data.ingredients where title = 'Сахар')),
    ((select id from kitchen_api_data.recipes where title = 'Блины'),
     (select id from kitchen_api_data.ingredients where title = 'Сливочное Масло')),
    ((select id from kitchen_api_data.recipes where title = 'Блины'),
     (select id from kitchen_api_data.ingredients where title = 'Куриное яйцо')),
    ((select id from kitchen_api_data.recipes where title = 'Пепперони'),
     (select id from kitchen_api_data.ingredients where title = 'Пшеничная мука')),
    ((select id from kitchen_api_data.recipes where title = 'Пепперони'),
     (select id from kitchen_api_data.ingredients where title = 'Пармезан')),
    ((select id from kitchen_api_data.recipes where title = 'Пепперони'),
     (select id from kitchen_api_data.ingredients where title = 'Колбаса')),
    ((select id from kitchen_api_data.recipes where title = 'Пепперони'),
     (select id from kitchen_api_data.ingredients where title = 'Куриное яйцо')),
    ((select id from kitchen_api_data.recipes where title = 'Карбонара'),
     (select id from kitchen_api_data.ingredients where title = 'Спагетти')),
    ((select id from kitchen_api_data.recipes where title = 'Карбонара'),
     (select id from kitchen_api_data.ingredients where title = 'Пармезан'));


-- migrate:down