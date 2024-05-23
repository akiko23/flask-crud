import uuid

from flask import Flask
import psycopg2
from psycopg2.extras import RealDictCursor
from flask import request
from psycopg2.sql import SQL, Literal
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
app.json.ensure_ascii = False

connection = psycopg2.connect(
    host=os.getenv('POSTGRES_HOST') if os.getenv('DEBUG_MODE') == 'false' else 'localhost',
    port=os.getenv('POSTGRES_PORT'),
    database=os.getenv('POSTGRES_DB'),
    user=os.getenv('POSTGRES_USER'),
    password=os.getenv('POSTGRES_PASSWORD'),
    cursor_factory=RealDictCursor
)
connection.autocommit = True


@app.get("/recipes")
def get_recipes():
    query = """
with
  recipes_with_ingredients as (
	select
	  r.id,
	  r.title,
	  r.description,
	  r.category,
	  coalesce(jsonb_agg(jsonb_build_object(
	    'id', i.id, 'title', i.title, 'category', i.category, 'price', i.price))
	      filter (where i.id is not null), '[]') as ingredients
	from kitchen_api_data.recipes r
	left join kitchen_api_data.recipes_ingredients ri on r.id = ri.recipe_id
	left join kitchen_api_data.ingredients i on i.id = ri.ingredient_id
	group by r.id
  ),
  recipes_with_comments as (
	select
	  rc.id,
	  coalesce(json_agg(json_build_object(
	    'id', c.id, 'text', c.text, 'published_on', c.published_on))
	      filter (where c.id is not null), '[]')
	        as comments
	from kitchen_api_data.recipes rc
	left join kitchen_api_data.comments c on rc.id = c.recipe_id
	group by rc.id
  )
select rwi.id, rwi.title, description, rwi.category, ingredients, comments
from recipes_with_ingredients rwi
join recipes_with_comments rwc on rwi.id = rwc.id
"""

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result


@app.post('/recipes')
def create_recipe():
    body = request.json

    title = body['title']
    description = body['description']
    category = body['category']

    query = SQL("""
insert into kitchen_api_data.recipes(title, description, category)
values ({title}, {description}, {category})
returning id
""").format(title=Literal(title), description=Literal(description), category=Literal(category))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchone()

    return result


@app.put('/recipes/<uuid:id>')
def update_recipe(id: uuid.UUID):
    body = request.json

    title = body['title']
    description = body['description']
    category = body['category']

    query = SQL("""
update kitchen_api_data.recipes
set 
  title = {title}, 
  description = {description},
  category = {category}
where id = {id}
returning id
""").format(title=Literal(title), description=Literal(description),
            category=Literal(category), id=Literal(str(id)))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', 404

    return '', 204


@app.get('/recipes/find_by_title')
def get_film_by_title():
    title = request.args.get('title')

    query = SQL("""
select id, title, description, category
from kitchen_api_data.recipes
where title ilike {title}
""").format(title=Literal('%' + title + '%'))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result


@app.get('/recipes/find_by_category')
def get_recipes_by_category():
    category = request.args.get('category')

    query = SQL("""
select id, title, description, category
from kitchen_api_data.recipes
where category ilike {category}
""").format(category=Literal(category))

    with connection.cursor() as cursor:
        cursor.execute(query)
        result = cursor.fetchall()

    return result


@app.delete('/recipes/<uuid:id>')
def delete_recipe(id: uuid.UUID):
    delete_recipe_stmt = SQL("delete from kitchen_api_data.recipes where id = {id} returning id").format(
        id=Literal(str(id)))

    with connection.cursor() as cursor:
        cursor.execute(delete_recipe_stmt)
        result = cursor.fetchall()

    if len(result) == 0:
        return '', 404

    return '', 204


if __name__ == '__main__':
    app.run(port=os.getenv('FLASK_PORT'))
