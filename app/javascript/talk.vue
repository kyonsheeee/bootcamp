<template lang="pug">
.thread-list-item
  .thread-list-item__inner
    .thread-list-item__user
      user-icon(
        :user='user',
        link_class='a-user-name',
        blockClassSuffix='thread-list-item'
      )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          h2.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link(
              :href='`/talks/${talk.id}`',
              itemprop='url'
            )
              | {{ user.long_name }} さんの相談部屋
      hr.thread-list-item__row-separator(v-if='talk.has_any_comments')
      .thread-list-item__row(v-if='talk.has_any_comments')
        .thread-list-item-meta__items
          .thread-list-item-meta__item
            .thread-list-item-comment
              .thread-list-item-comment__label
                | コメント ({{ talk.number_of_comments }})
              .thread-list-item-comment__user-icons
                img.a-user-icon(:src='talk.last_comment_user_icon')
              .thread-list-item-comment__label
                | 〜 {{ talk.last_commented_at }}
              .thread-list-item-comment__label(
                v-if='talk.last_comment_user.admin'
              )
                | (管理者)
              .thread-list-item-comment__label(v-else)
                | ({{ user.login_name }})
</template>
<script>
import UserIcon from './user-icon'
export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    user: { type: Object, required: true },
    talk: { type: Object, required: true }
  }
}
</script>
