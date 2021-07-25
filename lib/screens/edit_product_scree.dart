import 'package:flutter/material.dart';
import '../providers/product.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "EditProductScreen";

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = new GlobalKey<FormState>();
  var _editedProduct =
      Product(title: "", id: "", description: "", price: 0, imageUrl: "");

  bool isInit =
      false; //this variable we will used to initialize product in didChangeDependencies only once.
  bool _isLoading =
      false; //we will use this variable to render on basis of is product added to server of it is still ongoing

  var initValues = {
    "title": "",
    "price": "",
    "description": "",
    "imageURL": ""
  };


  @override
  void dispose() {
    // TODO: implement dispose
    //it is good to dispose custom focus node
    //because it leads to memory leaks and degrading performance.
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!isInit) {
      final productId = ModalRoute.of(context)!.settings.arguments as String;
      //This productId can be empty when we click icon on manage Product page to add new Product
      //so we have to check if product id is empty then we can use getItemById
      if (productId != "") {
        _editedProduct = Provider.of<Products>(context, listen: false)
            .getItemById(productId);

        initValues = {
          "title": _editedProduct.title,
          "price": _editedProduct.price.toString(),
          "description": _editedProduct.description,
          // "imageURL":_editedProduct.imageUrl,
          "imageURL": "",
        };

        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  void _saveForm() async{
    print("function triggered");
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      //the validate method return a boolean and any of the validation if wrong then it return false else true
      return;
    }
    _form.currentState
        ?.save(); //once we have saved file from form, then we are going to add the data to server
    //so we will now show a circular progress bar.

    setState(() {
      _isLoading = true; //this will set isLoading to true and due to which in our widget tree
      //we will render the circularProgressBar.
    });

    if (_editedProduct.id == "") {

      try{
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      }
      catch(error){//now the error we are getting in addProduct method we can handle it here.
        // print(error); //we can print error and to user we can alert them
        print("Catch");
        await showDialog(context: context, builder: (ctx) =>
            AlertDialog(
              title: Text("An Error Occurred !"),
              content: Text("Something we wrong."),
              actions: <Widget>[
                TextButton(child: Text("Ok"), onPressed: (){
                  Navigator.of(ctx).pop(); //removing then alert box
                },)
              ],
            )
        );
        //if we not handle the error then our app crash and the circularProgress bar continue rotating.
      }
      // finally{
      //   print("finally");
      //
      // }

    } else {

      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Product "),
        actions: [
          IconButton(onPressed: () => _saveForm(), icon: Icon(Icons.save)),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValues["title"],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).requestFocus(
                            _priceFocusNode); //switching focus from title to priceFocusNode
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: value as String,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty)
                          return "Enter a title"; //if we return a string then validation is unsuccessful
                        return null; //if we return null the validation is true
                      },
                    ),
                    TextFormField(
                      initialValue: initValues["price"],
                      decoration: InputDecoration(labelText: "Price"),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: _editedProduct.description,
                          price: double.parse(value as String),
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) return "Enter a price";
                        if (double.tryParse(value) == null)
                          return "Enter a valid number";
                        if (double.parse(value) <= 10.0)
                          return "Enter a amount greater than \$10";
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValues["description"],
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      textInputAction: TextInputAction.newline,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _editedProduct = Product(
                          title: _editedProduct.title,
                          id: _editedProduct.id,
                          isFavourite: _editedProduct.isFavourite,
                          description: value as String,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                        );
                      },
                      validator: (value) {
                        if (value!.isEmpty) return "Enter a description";
                        if (value.length <= 10)
                          return "Description should be atleast 10 character long";
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                            height: 100,
                            width: 100,
                            margin: EdgeInsets.only(right: 10, top: 8),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
                            child: _imageUrlController.text.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text("Enter a Url"),
                                        Icon(Icons.image),
                                      ],
                                    ),
                                  )
                                : FittedBox(
                                    child: Image.network(
                                      _imageUrlController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                        Expanded(
                          child: TextFormField(
                            // initialValue: initValues["imageURL"], //when we use controller then we can't use initialValue;
                            decoration: InputDecoration(labelText: "Image Url"),
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                title: _editedProduct.title,
                                id: _editedProduct.id,
                                isFavourite: _editedProduct.isFavourite,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value as String,
                              );
                            },
                            validator: (value) {
                              if (value!.isEmpty) return "Enter a URL";
                              if (!value.startsWith("http") ||
                                  !value.startsWith("https"))
                                return "Enter a valid URL";
                              // if(!value.endsWith(".png") || !value.endsWith(".jpg") || !value.endsWith(".jpeg")) return "Enter a valid image URL";
                              return null;
                            },
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
