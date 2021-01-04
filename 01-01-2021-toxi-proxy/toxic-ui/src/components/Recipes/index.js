import React from "react"
import "./styles.css"
import axios from "axios"


class Recipes extends React.Component {

  state = {
    recipes: [],
    error: false,
    loading: false
  }
  buttonHandler = (e) => {

    e.preventDefault()
    console.log("entering the click state")  
    this.setState({
      loading: true,
      error: false
    })

    const instance = axios.create({
      baseURL: "http://localhost/toxic-api",
      headers: { 
        'Access-Control-Allow-Origin': "*",
        'Content-Type': "application/json"
      },
      timeout: 2000
    })

    instance.get('/recipes', {headers: {'Content-Type': 'application/x-www-form-urlencoded'}})
      .then((response) => {
        this.setState({
          recipes: response.data,
          loading: false,
          error: false
        })
      })
      .catch((error) => {
        console.log(error)
        this.setState({
          error: true,
          loading: false
        })
      }) 
  }

  createRecipeBox = () => {
    return this.state.recipes.map( (recipe) => {
      return (
        <div className="recipeModal">
          <span>Name: {recipe.name}</span>
          <span>Cooking Time: {recipe.cooking_time}</span>
        </div>
      )
    })
  }

  createHoldingBox = () => {
    return (
      <div className="holdingBox">
        <h4>Something went wrong!!!!</h4>
      </div>
    )
  }
  render() {
    return (
      <>
        <button className="recipe-button" onClick={this.buttonHandler}>Get all Recipes</button>
        <div className="recipe-result-wrapper">
          <h3>All Recipes</h3>
          { this.state.loading?<div className="load"></div>:null}
          <div className="allRecipes">{this.state.error?this.createHoldingBox():this.createRecipeBox()}</div>
        </div>
      </>
    )
  }
}

export default Recipes