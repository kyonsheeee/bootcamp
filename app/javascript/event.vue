<template lang="pug">
.thread-list-item(:class='{ "is-wip": event.wip }')
  .thread-list-item__inner
    .thread-list-item__user
      user-icon(
        :user='event.user',
        link_class='a-user-name',
        blockClassSuffix='thread-list-item'
      )
    .thread-list-item__rows
      .thread-list-item__row
        .thread-list-item-title
          .thread-list-item-title__icon.is-wip(v-if='event.wip') WIP
          .thread-list-item-title__icon.is-ended(v-else-if='event.ended') 終了
          h2.thread-list-item-title__title(itemprop='name')
            a.thread-list-item-title__link(:href='event.url', itemprop='url')
              | {{ event.title }}
      .thread-list-item__row
        a.a-user-name(:href='event.user.url')
          | {{ event.user.long_name }}
      .thread-list-item__row
        .thread-list-item-meta
          .thread-list-item-meta__items
            .thread-list-item-meta__item
              time.a-meta(:datetime='event.start_at')
                span.a-meta__label
                  | 開催日時
                span.a-meta__value
                  | {{ event.start_at_localized }}
            .thread-list-item-meta__item
              .a-meta
                | 参加者（{{ event.participants_count }}名 / {{ event.capacity }}名）
            .thread-list-item-meta__item(v-if='event.waitlist_count > 0')
              .a-meta
                | 補欠者（{{ event.waitlist_count }}名）
            .thread-list-item-meta__item(v-if='event.comments_count > 0')
              .a-meta
                | コメント（{{ event.comments_count }}）
</template>

<script>
import UserIcon from './user-icon'

export default {
  components: {
    'user-icon': UserIcon
  },
  props: {
    event: { type: Object, required: true }
  }
}
</script>
