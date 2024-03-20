from sqlalchemy.orm import DeclarativeBase
from sqlalchemy import Column as mapped_column, Integer, String, ForeignKey

class Base(DeclarativeBase):
    pass

class User(Base):
    __tablename__ = 'users'
    id = mapped_column(Integer, primary_key=True)
    username = mapped_column(String, unique=True)
    password = mapped_column(String)

class Entity(Base):
    __tablename__ = 'entities'
    id = mapped_column(Integer, primary_key=True)
    name = mapped_column(String)

class Player(Base):
    __tablename__ = 'players'
    id = mapped_column(Integer, primary_key=True)
    entity_id = mapped_column(Integer, ForeignKey('entities.id'), unique=True)
    instanced_entity_id = mapped_column(Integer, ForeignKey('instanced_entities.entity_id'), unique=True)
    user_id = mapped_column(Integer, ForeignKey('users.id'), unique=True)
    image_index = mapped_column(Integer, default=0)

class InstancedEntity(Base):
    __tablename__ = 'instanced_entities'
    id = mapped_column(Integer, primary_key=True)
    entity_id = mapped_column(Integer, ForeignKey('entities.id'))
    x = mapped_column(Integer)
    y = mapped_column(Integer)
