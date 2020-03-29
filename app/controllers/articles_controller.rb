class ArticlesController < ApplicationController
  skip_before_action :authorized, only: [:save_mobile]

  def index
    @articles = Article.where(user: current_user).sort_by(&:created_at).reverse

    @new_article = Article.new

    render :list
  end

  def save_bookmarklet
    url = params[:url]&.strip
    title = RequestHelper.extract_title_from_page(url)

    new_article = Article.new(user: current_user, url: url, title: title)

    if new_article.save
      flash[:success] = 'Saved successfully.'
    else
      flash[:error] = new_article.errors.full_messages.to_sentence
    end
    redirect_to :articles
  rescue
    flash[:error] = 'There was an issue saving this URL.'
    redirect_to :articles
  end

  def save_mobile
    unless user = User.find_by(account_number: params[:account_number].delete(' '))
      return render json: 'This user does not exist.'
    end

    url = params[:url]&.strip
    title = RequestHelper.extract_title_from_page(url)
    new_article = Article.new(user: user, url: url, title: title)

    if new_article.save
      head :ok
    else
      render json: new_article.errors.full_messages.to_sentence
    end
  rescue
    render json: { error: 'There was an issue saving this URL.' }
  end

  def create
    url = params.dig(:article, :url)&.strip
    title = RequestHelper.extract_title_from_page(url)

    new_article = Article.new(user: current_user, url: url, title: title)

    if new_article.save
      flash[:success] = 'Saved successfully.'
    else
      flash[:error] = new_article.errors.full_messages.to_sentence
    end
    redirect_to :articles
  rescue
    flash[:error] = 'There was an issue saving this URL.'
    redirect_to :articles
  end

  def destroy
    @article = Article.find(params[:id])
    if @article.destroy
      flash[:success] = 'Marked as read successfully.'
    else
      flash[:error] = 'There was an issue marking this article as read.'
    end
    redirect_to :articles
  end
end
