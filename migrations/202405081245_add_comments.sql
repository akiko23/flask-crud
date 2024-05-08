-- migrate:up

insert into kitchen_api_data.comments(recipe_id, text)
values
    ((select id from kitchen_api_data.recipes where title = 'Борщ'),
     'Очень вкусно, прям как у моей покойной бабки'),
    ((select id from kitchen_api_data.recipes where title = 'Пепперони'),
     'Норм'),
    ((select id from kitchen_api_data.recipes where title = 'Пепперони'),
     'Итальянцы тебя закопают');

-- migrate:down